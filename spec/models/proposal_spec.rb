# coding: utf-8
require "rails_helper"

describe Proposal do
  let(:proposal) { build(:proposal) }

  describe "Concerns" do
    it_behaves_like "has_public_author"
    it_behaves_like "notifiable"
    it_behaves_like "map validations"
  end

  it "is valid" do
    expect(proposal).to be_valid
  end

  it "is not valid without an author" do
    proposal.author = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without a summary" do
    proposal.summary = nil
    expect(proposal).not_to be_valid
  end

  describe "#title" do
    it "is not valid without a title" do
      proposal.title = nil
      expect(proposal).not_to be_valid
    end

    it "is not valid when very short" do
      proposal.title = "abc"
      expect(proposal).not_to be_valid
    end

    it "is not valid when very long" do
      proposal.title = "a" * 81
      expect(proposal).not_to be_valid
    end
  end

  describe "#description" do
    it "is sanitized" do
      proposal.description = "<script>alert('danger');</script>"
      proposal.valid?
      expect(proposal.description).to eq("alert('danger');")
    end

    it "is not valid when very long" do
      proposal.description = "a" * 6001
      expect(proposal).not_to be_valid
    end
  end

  describe "#video_url" do
    it "is not valid when URL is not from Youtube or Vimeo" do
      proposal.video_url = "https://twitter.com"
      expect(proposal).not_to be_valid
    end

    it "is valid when URL is from Youtube or Vimeo" do
      proposal.video_url = "https://vimeo.com/112681885"
      expect(proposal).to be_valid
    end
  end

  describe "#responsible_name" do
    it "is mandatory" do
      proposal.responsible_name = nil
      expect(proposal).not_to be_valid
    end

    it "is not valid when very short" do
      proposal.responsible_name = "abc"
      expect(proposal).not_to be_valid
    end

    it "is not valid when very long" do
      proposal.responsible_name = "a" * 61
      expect(proposal).not_to be_valid
    end

    it "is the document_number if level two user" do
      author = create(:user, :level_two, document_number: "12345678Z")
      proposal.author = author
      proposal.responsible_name = nil

      expect(proposal).to be_valid
      proposal.responsible_name = "12345678Z"
    end

     it "is the document_number if level three user" do
      author = create(:user, :level_three, document_number: "12345678Z")
      proposal.author = author
      proposal.responsible_name = nil

      expect(proposal).to be_valid
      proposal.responsible_name = "12345678Z"
     end

    it "is not updated when the author is deleted" do
      author = create(:user, :level_three, document_number: "12345678Z")
      proposal.author = author
      proposal.save

      proposal.author.erase

      proposal.save
      expect(proposal.responsible_name).to eq "12345678Z"
    end
  end

  describe "tag_list" do
    it "sanitizes the tag list" do
      proposal.tag_list = "user_id=1"
      proposal.valid?
      expect(proposal.tag_list).to eq(["user_id1"])
    end

    it "is not valid with a tag list of more than 6 elements" do
      proposal.tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa", "Huelgas"]
      expect(proposal).not_to be_valid
    end

    it "is valid with a tag list of up to 6 elements" do
      proposal.tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
      expect(proposal).to be_valid
    end
  end

  it "is not valid without accepting terms of service" do
    proposal.terms_of_service = nil
    expect(proposal).not_to be_valid
  end

  it "has a code" do
    Setting["proposal_code_prefix"] = "TEST"
    proposal = create(:proposal)
    expect(proposal.code).to eq "TEST-#{proposal.created_at.strftime('%Y-%m')}-#{proposal.id}"

    Setting["proposal_code_prefix"] = "MAD"
  end

  describe "#editable?" do
    let(:proposal) { create(:proposal) }

    before {Setting["max_votes_for_proposal_edit"] = 5}
    after {Setting["max_votes_for_proposal_edit"] = 1000}

    it "is true if proposal has no votes yet" do
      expect(proposal.total_votes).to eq(0)
      expect(proposal.editable?).to be true
    end

    it "is true if proposal has less than limit votes" do
      create_list(:vote, 4, votable: proposal)
      expect(proposal.total_votes).to eq(4)
      expect(proposal.editable?).to be true
    end

    it "is false if proposal has more than limit votes" do
      create_list(:vote, 6, votable: proposal)
      expect(proposal.total_votes).to eq(6)
      expect(proposal.editable?).to be false
    end
  end

  describe "#votable_by?" do
    let(:proposal) { create(:proposal) }

    it "is true for level two verified users" do
      user = create(:user, residence_verified_at: Time.current, confirmed_phone: "666333111")
      expect(proposal.votable_by?(user)).to be true
    end

    it "is true for level three verified users" do
      user = create(:user, verified_at: Time.current)
      expect(proposal.votable_by?(user)).to be true
    end

    it "is false for anonymous users" do
      user = create(:user)
      expect(proposal.votable_by?(user)).to be false
    end
  end

  describe "#register_vote" do
    let(:proposal) { create(:proposal) }

    describe "from level two verified users" do
      it "registers vote" do
        user = create(:user, residence_verified_at: Time.current, confirmed_phone: "666333111")
        expect {proposal.register_vote(user, "yes")}.to change{proposal.reload.votes_for.size}.by(1)
      end
    end

    describe "from level three verified users" do
      it "registers vote" do
        user = create(:user, verified_at: Time.current)
        expect {proposal.register_vote(user, "yes")}.to change{proposal.reload.votes_for.size}.by(1)
      end
    end

    describe "from anonymous users" do
      it "does not register vote" do
        user = create(:user)
        expect {proposal.register_vote(user, "yes")}.to change{proposal.reload.votes_for.size}.by(0)
      end
    end

    it "does not register vote for archived proposals" do
      user = create(:user, verified_at: Time.current)
      archived_proposal = create(:proposal, :archived)

      expect {archived_proposal.register_vote(user, "yes")}.to change{proposal.reload.votes_for.size}.by(0)
    end
  end

  describe "#cached_votes_up" do

    describe "with deprecated long tag list" do

      it "increases number of cached_total_votes" do
        proposal = create(:proposal)

        tag_list = ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6", "tag7"]
        proposal.update_attribute(:tag_list, tag_list)

        expect(proposal.update_cached_votes).to eq(true)
      end

    end
  end

  describe "#hot_score" do
    let(:now) { Time.current }

    it "period is correctly calculated to get exact votes per day" do
      new_proposal = create(:proposal, created_at: 23.hours.ago)
      2.times { new_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(new_proposal.hot_score).to be 2

      old_proposal = create(:proposal, created_at: 25.hours.ago)
      2.times { old_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(old_proposal.hot_score).to be 1

      older_proposal = create(:proposal, created_at: 49.hours.ago)
      3.times { older_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(old_proposal.hot_score).to be 1
    end

    it "remains the same for not voted proposals" do
      new = create(:proposal, created_at: now)
      old = create(:proposal, created_at: 1.day.ago)
      older = create(:proposal, created_at: 2.month.ago)
      expect(new.hot_score).to be 0
      expect(old.hot_score).to be 0
      expect(older.hot_score).to be 0
    end

    it "increases for proposals with more positive votes" do
      more_positive_votes = create(:proposal)
      2.times { more_positive_votes.vote_by(voter: create(:user), vote: "yes") }

      less_positive_votes = create(:proposal)
      less_positive_votes.vote_by(voter: create(:user), vote: "yes")

      expect(more_positive_votes.hot_score).to be > less_positive_votes.hot_score
    end

    it "increases for proposals with the same amount of positive votes within less days" do
      newer_proposal = create(:proposal, created_at: now)
      5.times { newer_proposal.vote_by(voter: create(:user), vote: "yes") }

      older_proposal = create(:proposal, created_at: 2.days.ago)
      5.times { older_proposal.vote_by(voter: create(:user), vote: "yes") }

      expect(newer_proposal.hot_score).to be > older_proposal.hot_score
    end

    it "increases for proposals voted within the period (last month by default)" do
      newer_proposal = create(:proposal, created_at: 2.months.ago)
      20.times { create(:vote, votable: newer_proposal, created_at: 3.days.ago) }

      older_proposal = create(:proposal, created_at: 2.months.ago)
      20.times { create(:vote, votable: older_proposal, created_at: 40.days.ago) }

      expect(newer_proposal.hot_score).to be > older_proposal.hot_score
    end

    describe "actions which affect it" do

      let(:proposal) { create(:proposal) }

      before do
        5.times { proposal.vote_by(voter: create(:user), vote: "yes") }
        2.times { proposal.vote_by(voter: create(:user), vote: "no") }
      end

      it "increases with positive votes" do
        previous = proposal.hot_score
        3.times { proposal.vote_by(voter: create(:user), vote: "yes") }
        expect(previous).to be < proposal.hot_score
      end

      it "decreases with negative votes" do
        previous = proposal.hot_score
        3.times { proposal.vote_by(voter: create(:user), vote: "no") }
        expect(previous).to be > proposal.hot_score
      end
    end
  end

  describe "custom tag counters when hiding/restoring" do
    it "decreases the tag counter when hiden, and increases it when restored" do
      proposal = create(:proposal, tag_list: "foo")
      tag = ActsAsTaggableOn::Tag.where(name: "foo").first
      expect(tag.proposals_count).to eq(1)

      proposal.hide
      expect(tag.reload.proposals_count).to eq(0)

      proposal.restore
      expect(tag.reload.proposals_count).to eq(1)
    end
  end

  describe "#confidence_score" do

    it "takes into account votes" do
      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 100)
      expect(proposal.confidence_score).to eq(10000)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 0)
      expect(proposal.confidence_score).to eq(1)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 75)
      expect(proposal.confidence_score).to eq(7500)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 750)
      expect(proposal.confidence_score).to eq(75000)

      proposal = create(:proposal, :with_confidence_score, cached_votes_up: 10)
      expect(proposal.confidence_score).to eq(1000)
    end

    describe "actions which affect it" do
      let(:proposal) { create(:proposal, :with_confidence_score) }

      it "increases with like" do
        previous = proposal.confidence_score
        5.times { proposal.register_vote(create(:user, verified_at: Time.current), true) }
        expect(previous).to be < proposal.confidence_score
      end
    end

  end

  describe "cache" do
    let(:proposal) { create(:proposal) }

    it "expires cache when it has a new comment" do
      expect { create(:comment, commentable: proposal) }
      .to change { proposal.updated_at }
    end

    it "expires cache when it has a new vote" do
      expect { create(:vote, votable: proposal) }
      .to change { proposal.updated_at }
    end

    it "expires cache when it has a new flag" do
      expect { create(:flag, flaggable: proposal) }
      .to change { proposal.reload.updated_at }
    end

    it "expires cache when it has a new tag" do
      expect { proposal.update(tag_list: "new tag") }
      .to change { proposal.updated_at }
    end

    it "expires cache when hidden" do
      expect { proposal.hide }
      .to change { proposal.updated_at }
    end

    it "expires cache when the author is hidden" do
      expect { proposal.author.hide }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end

    it "expires cache when the author is erased" do
      expect { proposal.author.erase }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end

    it "expires cache when its author changes" do
      expect { proposal.author.update(username: "Eva") }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end

    it "expires cache when the author's organization get verified" do
      create(:organization, user: proposal.author)
      expect { proposal.author.organization.verify }
      .to change { [proposal.reload.updated_at, proposal.author.updated_at] }
    end
  end

  describe "voters" do

    it "returns users that have voted for the proposal" do
      proposal = create(:proposal)
      voter1 = create(:user, :level_two)
      voter2 = create(:user, :level_two)
      voter3 = create(:user, :level_two)

      create(:vote, voter: voter1, votable: proposal)
      create(:vote, voter: voter2, votable: proposal)

      expect(proposal.voters).to include(voter1)
      expect(proposal.voters).to include(voter2)
      expect(proposal.voters).not_to include(voter3)
    end

    it "does not return users that have been erased" do
      proposal = create(:proposal)
      voter1 = create(:user, :level_two)
      voter2 = create(:user, :level_two)

      create(:vote, voter: voter1, votable: proposal)
      create(:vote, voter: voter2, votable: proposal)
      voter2.erase

      expect(proposal.voters).to include(voter1)
      expect(proposal.voters).not_to include(voter2)
    end

    it "does not return users that have been blocked" do
      proposal = create(:proposal)
      voter1 = create(:user, :level_two)
      voter2 = create(:user, :level_two)

      create(:vote, voter: voter1, votable: proposal)
      create(:vote, voter: voter2, votable: proposal)
      voter2.block

      expect(proposal.voters).to include(voter1)
      expect(proposal.voters).not_to include(voter2)
    end

  end

  describe "search" do

    context "attributes" do

      it "searches by title" do
        proposal = create(:proposal, title: "save the world")
        results = described_class.search("save the world")
        expect(results).to eq([proposal])
      end

      it "searches by id" do
        proposal = create(:proposal, title: "free willy")
        results = described_class.search(proposal.id)
        expect(results).to eq([proposal])
      end

      it "searches by summary" do
        proposal = create(:proposal, summary: "basically...")
        results = described_class.search("basically")
        expect(results).to eq([proposal])
      end

      it "searches by description" do
        proposal = create(:proposal, description: "in order to save the world one must think about...")
        results = described_class.search("one must think")
        expect(results).to eq([proposal])
      end

      it "searches by author name" do
        author = create(:user, username: "Danny Trejo")
        proposal = create(:proposal, author: author)
        results = described_class.search("Danny")
        expect(results).to eq([proposal])
      end

      it "searches by parameterized id-title" do
        proposal = create(:proposal, title: "river cleanup")
        results = described_class.search(proposal.to_param)
        expect(results).to eq([proposal])
      end

      it "searches by geozone" do
        geozone = create(:geozone, name: "California")
        proposal = create(:proposal, geozone: geozone)
        results = described_class.search("California")
        expect(results).to eq([proposal])
      end

    end

    context "stemming" do

      it "searches word stems" do
        proposal = create(:proposal, summary: "Economía")

        results = described_class.search("economía")
        expect(results).to eq([proposal])

        results = described_class.search("econo")
        expect(results).to eq([proposal])

        results = described_class.search("eco")
        expect(results).to eq([proposal])
      end

    end

    context "accents" do
      it "searches with accents" do
        proposal = create(:proposal, summary: "difusión")

        results = described_class.search("difusion")
        expect(results).to eq([proposal])

        proposal2 = create(:proposal, summary: "estadisticas")
        results = described_class.search("estadísticas")
        expect(results).to eq([proposal2])

        proposal3 = create(:proposal, summary: "público")
        results = described_class.search("publico")
        expect(results).to eq([proposal3])
      end
    end

    context "case" do
      it "searches case insensite" do
        proposal = create(:proposal, title: "SHOUT")

        results = described_class.search("shout")
        expect(results).to eq([proposal])

        proposal2 = create(:proposal, title: "scream")
        results = described_class.search("SCREAM")
        expect(results).to eq([proposal2])
      end
    end

    context "tags" do
      it "searches by tags" do
        proposal = create(:proposal, tag_list: "Latina")

        results = described_class.search("Latina")
        expect(results.first).to eq(proposal)

        results = described_class.search("Latin")
        expect(results.first).to eq(proposal)
      end
    end

    context "order" do

      it "orders by weight" do
        proposal_title       = create(:proposal,  title:       "stop corruption")
        proposal_description = create(:proposal,  description: "stop corruption")
        proposal_summary     = create(:proposal,  summary:     "stop corruption")

        results = described_class.search("stop corruption")

        expect(results.first).to eq(proposal_title)
        expect(results.second).to eq(proposal_summary)
        expect(results.third).to eq(proposal_description)
      end

      it "orders by weight and then by votes" do
        title_some_votes    = create(:proposal, title: "stop corruption", cached_votes_up: 5)
        title_least_voted   = create(:proposal, title: "stop corruption", cached_votes_up: 2)
        title_most_voted    = create(:proposal, title: "stop corruption", cached_votes_up: 10)

        summary_most_voted  = create(:proposal, summary: "stop corruption", cached_votes_up: 10)

        results = described_class.search("stop corruption")

        expect(results.first).to eq(title_most_voted)
        expect(results.second).to eq(title_some_votes)
        expect(results.third).to eq(title_least_voted)
        expect(results.fourth).to eq(summary_most_voted)
      end

      it "gives much more weight to word matches than votes" do
        exact_title_few_votes    = create(:proposal, title: "stop corruption", cached_votes_up: 5)
        similar_title_many_votes = create(:proposal, title: "stop some of the corruption", cached_votes_up: 500)

        results = described_class.search("stop corruption")

        expect(results.first).to eq(exact_title_few_votes)
        expect(results.second).to eq(similar_title_many_votes)
      end

    end

    context "reorder" do

      it "is able to reorder by hot_score after searching" do
        lowest_score  = create(:proposal,  title: "stop corruption", cached_votes_up: 1)
        highest_score = create(:proposal,  title: "stop corruption", cached_votes_up: 2)
        average_score = create(:proposal,  title: "stop corruption", cached_votes_up: 3)

        lowest_score.update_column(:hot_score, 1)
        highest_score.update_column(:hot_score, 100)
        average_score.update_column(:hot_score, 10)

        results = described_class.search("stop corruption")

        expect(results.first).to eq(average_score)
        expect(results.second).to eq(highest_score)
        expect(results.third).to eq(lowest_score)

        results = results.sort_by_hot_score

        expect(results.first).to eq(highest_score)
        expect(results.second).to eq(average_score)
        expect(results.third).to eq(lowest_score)
      end

      it "is able to reorder by confidence_score after searching" do
        lowest_score  = create(:proposal,  title: "stop corruption", cached_votes_up: 1)
        highest_score = create(:proposal,  title: "stop corruption", cached_votes_up: 2)
        average_score = create(:proposal,  title: "stop corruption", cached_votes_up: 3)

        lowest_score.update_column(:confidence_score, 1)
        highest_score.update_column(:confidence_score, 100)
        average_score.update_column(:confidence_score, 10)

        results = described_class.search("stop corruption")

        expect(results.first).to eq(average_score)
        expect(results.second).to eq(highest_score)
        expect(results.third).to eq(lowest_score)

        results = results.sort_by_confidence_score

        expect(results.first).to eq(highest_score)
        expect(results.second).to eq(average_score)
        expect(results.third).to eq(lowest_score)
      end

      it "is able to reorder by created_at after searching" do
        recent  = create(:proposal,  title: "stop corruption", cached_votes_up: 1, created_at: 1.week.ago)
        newest  = create(:proposal,  title: "stop corruption", cached_votes_up: 2, created_at: Time.current)
        oldest  = create(:proposal,  title: "stop corruption", cached_votes_up: 3, created_at: 1.month.ago)

        results = described_class.search("stop corruption")

        expect(results.first).to eq(oldest)
        expect(results.second).to eq(newest)
        expect(results.third).to eq(recent)

        results = results.sort_by_created_at

        expect(results.first).to eq(newest)
        expect(results.second).to eq(recent)
        expect(results.third).to eq(oldest)
      end

      it "is able to reorder by most commented after searching" do
        least_commented = create(:proposal,  title: "stop corruption",  cached_votes_up: 1, comments_count: 1)
        most_commented  = create(:proposal,  title: "stop corruption",  cached_votes_up: 2, comments_count: 100)
        some_comments   = create(:proposal,  title: "stop corruption",  cached_votes_up: 3, comments_count: 10)

        results = described_class.search("stop corruption")

        expect(results.first).to eq(some_comments)
        expect(results.second).to eq(most_commented)
        expect(results.third).to eq(least_commented)

        results = results.sort_by_most_commented

        expect(results.first).to eq(most_commented)
        expect(results.second).to eq(some_comments)
        expect(results.third).to eq(least_commented)
      end

    end

    context "no results" do

      it "no words match" do
        create(:proposal, title: "save world")

        results = described_class.search("destroy planet")
        expect(results).to eq([])
      end

      it "too many typos" do
        create(:proposal, title: "fantastic")

        results = described_class.search("frantac")
        expect(results).to eq([])
      end

      it "too much stemming" do
        create(:proposal, title: "reloj")

        results = described_class.search("superrelojimetro")
        expect(results).to eq([])
      end

      it "empty" do
        create(:proposal, title: "great")

        results = described_class.search("")
        expect(results).to eq([])
      end

    end
  end

  describe "#last_week" do
    it "returns proposals created this week" do
      proposal = create(:proposal)
      expect(described_class.last_week).to include(proposal)
    end

    it "does not return proposals created more than a week ago" do
      proposal = create(:proposal, created_at: 8.days.ago)
      expect(described_class.last_week).not_to include(proposal)
    end
  end

  describe "for_summary" do

    context "categories" do

      it "returns proposals tagged with a category" do
        create(:tag, :category, name: "culture")
        proposal = create(:proposal, tag_list: "culture")

        expect(described_class.for_summary.values.flatten).to include(proposal)
      end

      it "does not return proposals tagged without a category" do
        create(:tag, :category, name: "culture")
        proposal = create(:proposal, tag_list: "parks")

        expect(described_class.for_summary.values.flatten).not_to include(proposal)
      end
    end

    context "districts" do

      it "returns proposals with a geozone" do
        california = create(:geozone, name: "california")
        proposal   = create(:proposal, geozone: california)

        expect(described_class.for_summary.values.flatten).to include(proposal)
      end

      it "does not return proposals without a geozone" do
        create(:geozone, name: "california")
        proposal = create(:proposal)

        expect(described_class.for_summary.values.flatten).not_to include(proposal)
      end
    end

    it "returns proposals created this week" do
      create(:tag, :category, name: "culture")
      proposal = create(:proposal, tag_list: "culture")
      expect(described_class.for_summary.values.flatten).to include(proposal)
    end

    it "does not return proposals created more than a week ago" do
      create(:tag, :category, name: "culture")
      proposal = create(:proposal, tag_list: "culture", created_at: 8.days.ago)
      expect(described_class.for_summary.values.flatten).not_to include(proposal)
    end

    it "orders proposals by votes" do
      create(:tag, :category, name: "culture")
      create(:proposal,  tag_list: "culture").update_column(:confidence_score, 2)
      create(:proposal, tag_list: "culture").update_column(:confidence_score, 10)
      create(:proposal, tag_list: "culture").update_column(:confidence_score, 5)

      results = described_class.for_summary.values.flatten

      expect(results.first.confidence_score).to  be(10)
      expect(results.second.confidence_score).to be(5)
      expect(results.third.confidence_score).to  be(2)
    end

    it "orders groups alphabetically" do
      create(:tag, :category, name: "health")
      create(:tag, :category, name: "culture")
      create(:tag, :category, name: "social services")

      health_proposal  = create(:proposal,  tag_list: "health")
      culture_proposal = create(:proposal,  tag_list: "culture")
      social_proposal  = create(:proposal,  tag_list: "social services")

      results = described_class.for_summary.values.flatten

      expect(results.first).to  eq(culture_proposal)
      expect(results.second).to eq(health_proposal)
      expect(results.third).to  eq(social_proposal)
    end

    it "returns proposals grouped by tag" do
      create(:tag, :category, name: "culture")
      create(:tag, :category, name: "health")

      proposal1 = create(:proposal, tag_list: "culture")
      proposal2 = create(:proposal, tag_list: "culture")
      proposal2.update_column(:confidence_score, 100)
      proposal3 = create(:proposal, tag_list: "health")

      proposal1.update_column(:confidence_score, 10)
      proposal2.update_column(:confidence_score, 9)

      expect(described_class.for_summary).to include("culture" => [proposal1, proposal2], "health" => [proposal3])
    end
  end

  describe "#to_param" do
    it "returns a friendly url" do
      expect(proposal.to_param).to eq "#{proposal.id} #{proposal.title}".parameterize
    end
  end

  describe "retired" do
    let!(:proposal1) { create(:proposal) }
    let!(:proposal2) { create(:proposal, retired_at: Time.current) }

    it "retired? is true" do
      expect(proposal1.retired?).to eq false
      expect(proposal2.retired?).to eq true
    end

    it "scope retired" do
      retired = described_class.retired

      expect(retired.size).to eq(1)
      expect(retired.first).to eq(proposal2)
    end

    it "scope not_retired" do
      not_retired = described_class.not_retired

      expect(not_retired.size).to eq(1)
      expect(not_retired.first).to eq(proposal1)
    end
  end

  describe "archived" do
    let!(:new_proposal)      { create(:proposal) }
    let!(:archived_proposal) { create(:proposal, :archived) }

    it "archived? is true only for proposals created more than n (configured months) ago" do
      expect(new_proposal.archived?).to eq false
      expect(archived_proposal.archived?).to eq true
    end

    it "scope archived" do
      archived = described_class.archived

      expect(archived.size).to eq(1)
      expect(archived.first).to eq(archived_proposal)
    end

    it "scope not archived" do
      not_archived = described_class.not_archived

      expect(not_archived.size).to eq(1)
      expect(not_archived.first).to eq(new_proposal)
    end
  end

  describe "selected" do
    let!(:not_selected_proposal) { create(:proposal) }
    let!(:selected_proposal)   { create(:proposal, :selected) }

    it "selected? is true" do
      expect(not_selected_proposal.selected?).to be false
      expect(selected_proposal.selected?).to be true
    end

    it "scope selected" do
      selected = Proposal.selected

      expect(selected.size).to be 1
      expect(selected.first).to eq selected_proposal
    end

    it "scope not_selected" do
      not_selected = Proposal.not_selected

      expect(not_selected.size).to be 1
      expect(not_selected.first).to eq not_selected_proposal
    end
  end

  describe "public_for_api scope" do
    it "returns proposals" do
      proposal = create(:proposal)
      expect(described_class.public_for_api).to include(proposal)
    end

    it "does not return hidden proposals" do
      proposal = create(:proposal, :hidden)
      expect(described_class.public_for_api).not_to include(proposal)
    end
  end

  describe "#user_to_notify" do

    it "returns voters and followers" do
      proposal = create(:proposal)
      voter = create(:user, :level_two)
      follower = create(:user, :level_two)
      follow = create(:follow, user: follower, followable: proposal)
      create(:vote, voter: voter, votable: proposal)

      expect(proposal.users_to_notify).to eq([voter, follower])
    end

    it "returns voters and followers discarding duplicates" do
      proposal = create(:proposal)
      voter_and_follower = create(:user, :level_two)
      follow = create(:follow, user: voter_and_follower, followable: proposal)
      create(:vote, voter: voter_and_follower, votable: proposal)

      expect(proposal.users_to_notify).to eq([voter_and_follower])
    end

    it "returns voters and followers except the proposal author" do
      author = create(:user, :level_two)
      proposal = create(:proposal, author: author)
      voter_and_follower = create(:user, :level_two)

      create(:follow, user: author, followable: proposal)
      create(:follow, user: voter_and_follower, followable: proposal)
      create(:vote, voter: author, votable: proposal)
      create(:vote, voter: voter_and_follower, votable: proposal)

      expect(proposal.users_to_notify).to eq([voter_and_follower])
    end

  end

  describe "#recommendations" do

    let(:user)     { create(:user) }

    it "does not return any proposals when user has not interests" do
      create(:proposal)

      expect(described_class.recommendations(user).size).to eq 0
    end

    it "returns proposals ordered by cached_votes_up" do
      proposal1 = create(:proposal, cached_votes_up: 1,  tag_list: "Sport")
      proposal2 = create(:proposal, cached_votes_up: 5,  tag_list: "Sport")
      proposal3 = create(:proposal, cached_votes_up: 10, tag_list: "Sport")
      proposal4 = create(:proposal, tag_list: "Sport")
      create(:follow, followable: proposal4, user: user)

      result = described_class.recommendations(user).sort_by_recommendations

      expect(result.first).to eq proposal3
      expect(result.second).to eq proposal2
      expect(result.third).to eq proposal1
    end

    it "returns proposals related with user interests" do
      proposal1 =  create(:proposal, tag_list: "Sport")
      proposal2 =  create(:proposal, tag_list: "Sport")
      proposal3 =  create(:proposal, tag_list: "Politics")
      create(:follow, followable: proposal1, user: user)

      result = described_class.recommendations(user)

      expect(result.size).to eq 1
      expect(result).to eq [proposal2]
    end

    it "does not return proposals when user is follower" do
      proposal1 =  create(:proposal, tag_list: "Sport")
      create(:follow, followable: proposal1, user: user)

      result = described_class.recommendations(user)

      expect(result.size).to eq 0
    end

    it "does not return proposals when user is the author" do
      proposal1 =  create(:proposal, author: user, tag_list: "Sport")
      proposal2 =  create(:proposal, tag_list: "Sport")
      proposal3 =  create(:proposal, tag_list: "Sport")
      create(:follow, followable: proposal3, user: user)

      result = described_class.recommendations(user)

      expect(result.size).to eq 1
      expect(result).to eq [proposal2]
    end

    it "does not return archived proposals" do
      proposal1 = create(:proposal, cached_votes_up: 5, tag_list: "Sport")
      proposal2 = create(:proposal, cached_votes_up: 5, tag_list: "Sport")
      archived_proposal = create(:proposal, :archived)
      create(:follow, followable: proposal1, user: user)

      result = described_class.recommendations(user)
      expect(result.size).to eq(1)
      expect(result).to eq([proposal2])
    end

    it "does not return already supported proposals" do
      proposal1 = create(:proposal, cached_votes_up: 5, tag_list: "Health")
      proposal2 = create(:proposal, cached_votes_up: 5, tag_list: "Health")
      proposal3 = create(:proposal, cached_votes_up: 5, tag_list: "Health")
      create(:vote, votable: proposal1, voter: user)
      create(:follow, followable: proposal2, user: user)

      result = described_class.recommendations(user)
      expect(result.size).to eq(1)
      expect(result).to eq([proposal3])
    end

  end

  describe "#send_new_actions_notification_on_create" do

    before do
      Setting["dashboard.emails"] = true
      ActionMailer::Base.deliveries.clear
    end

    after do
      Setting["dashboard.emails"] = nil
    end

    it "send notification after create when there are new actived actions" do
      create(:dashboard_action, :proposed_action, :active, day_offset: 0, published_proposal: false)
      create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: false)

      create(:proposal, :draft)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "Not send notification after create when there are not new actived actions" do
      create(:dashboard_action, :proposed_action, :active, day_offset: 1, published_proposal: false)
      create(:dashboard_action, :resource, :active, day_offset: 1, published_proposal: false)

      create(:proposal, :draft)

      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

  end

  describe "#send_new_actions_notification_on_published" do

    before do
      Setting["dashboard.emails"] = true
      ActionMailer::Base.deliveries.clear
    end

    after do
      Setting["dashboard.emails"] = nil
    end

    it "send notification after published when there are new actived actions" do
      create(:dashboard_action, :proposed_action, :active, day_offset: 0, published_proposal: true)
      create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: true)

      proposal = create(:proposal, :draft)
      proposal.publish

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "Not send notification after published when there are not new actived actions" do
      create(:dashboard_action, :proposed_action, :active, day_offset: 1, published_proposal: true)
      create(:dashboard_action, :resource, :active, day_offset: 1, published_proposal: true)

      proposal = create(:proposal, :draft)
      proposal.publish

      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

  end

  describe "milestone_tags" do

    context "without milestone_tags" do

      let(:proposal) {create(:proposal)}

      it "do not have milestone_tags" do
        expect(proposal.milestone_tag_list).to eq([])
        expect(proposal.milestone_tags).to eq([])
      end

      it "add a new milestone_tag" do
        proposal.milestone_tag_list = "tag1,tag2"

        expect(proposal.milestone_tag_list).to eq(["tag1", "tag2"])
      end
    end

    context "with milestone_tags" do

      let(:proposal) {create(:proposal, :with_milestone_tags)}

      it "has milestone_tags" do
        expect(proposal.milestone_tag_list.count).to eq(1)
      end
    end
  end

end
