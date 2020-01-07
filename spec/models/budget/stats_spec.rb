require "rails_helper"

describe Budget::Stats do
  let(:budget) { create(:budget, :finished) }
  let(:stats) { Budget::Stats.new(budget) }
  let(:investment) { create(:budget_investment, :selected, budget: budget) }

  describe "#participants" do
    let!(:author) { investment.author }
    let!(:author_and_voter) { create(:user, :hidden, votables: [investment]) }
    let!(:voter) { create(:user, votables: [investment]) }
    let!(:voter_and_balloter) { create(:user, votables: [investment], ballot_lines: [investment]) }
    let!(:balloter) { create(:user, :hidden, ballot_lines: [investment]) }
    let!(:poll_balloter) { create(:user, :level_two) }
    let!(:non_participant) { create(:user, :level_two) }

    before do
      create(:budget_investment, :selected, budget: budget, author: author_and_voter)

      create(:poll_voter, :from_booth, user: poll_balloter, budget: budget)

      create(:poll_voter, :from_booth, user: non_participant, budget: create(:budget))
    end

    it "returns unique participants, including authors and hidden users" do
      expect(stats.participants).to match_array(
        [author, author_and_voter, voter, voter_and_balloter, balloter, poll_balloter]
      )
      expect(stats.total_participants).to be 6
    end
  end

  describe "#total_participants_support_phase" do
    it "returns the number of total participants in the support phase" do
      2.times { create(:vote, votable: investment) }
      create(:budget_ballot_line, investment: investment)

      expect(stats.total_participants_support_phase).to be 2
    end

    it "counts a user who is voter and balloter" do
      create(:user, votables: [investment], ballot_lines: [investment])

      expect(stats.total_participants_support_phase).to be 1
    end
  end

  describe "#total_participants_vote_phase" do
    it "returns the number of total participants in the votes phase" do
      2.times { create(:budget_ballot_line, investment: investment) }
      create(:vote, votable: investment)

      expect(stats.total_participants_vote_phase).to be 2
    end

    it "counts a user who is voter and balloter" do
      create(:user, votables: [investment], ballot_lines: [investment])

      expect(stats.total_participants_vote_phase).to be 1
    end

    it "includes balloters and poll balloters" do
      create(:budget_ballot_line, investment: investment)
      create(:poll_voter, :from_booth, budget: budget)

      expect(stats.total_participants_vote_phase).to be 2
    end

    it "counts once a user who is balloter and poll balloter" do
      poller_and_balloter = create(:user, :level_two, ballot_lines: [investment])
      create(:poll_voter, :from_booth, user: poller_and_balloter, budget: budget)

      expect(stats.total_participants_vote_phase).to be 1
    end

    it "doesn't count nil user ids" do
      create(:budget_ballot_line, investment: investment,
        ballot: create(:budget_ballot, budget: budget.reload, user: nil, physical: true)
      )

      expect(stats.total_participants_vote_phase).to be 0
    end
  end

  describe "#total_budget_investments" do
    it "returns the number of total budget investments" do
      2.times { create(:budget_investment, budget: budget) }
      create(:budget_investment, budget: create(:budget))

      expect(stats.total_budget_investments).to be 2
    end
  end

  describe "#total_votes" do
    it "returns the number of total votes" do
      create(:budget_ballot_line, investment: investment)
      create(:budget_ballot_line, investment: create(:budget_investment, :selected, budget: budget))

      expect(stats.total_votes).to be 2
    end
  end

  describe "#total_selected_investments" do
    it "returns the number of total selected investments" do
      3.times { create(:budget_investment, :selected, budget: budget) }
      create(:budget_investment, :selected, budget: create(:budget))
      create(:budget_investment, :unfeasible, budget: budget)

      expect(stats.total_selected_investments).to be 3
    end
  end

  describe "#total_unfeasible_investments" do
    it "returns the number of total unfeasible investments" do
      3.times { create(:budget_investment, :unfeasible, budget: budget) }
      create(:budget_investment, :unfeasible, budget: create(:budget))
      create(:budget_investment, :selected, budget: budget)

      expect(stats.total_unfeasible_investments).to be 3
    end
  end

  describe "Participants by gender" do
    before do
      5.times { create(:user, gender: "male") }
      4.times { create(:user, gender: "female") }
      1.times { create(:user, gender: "other") }
      create(:user, gender: nil)

      allow(stats).to receive(:participants).and_return(User.all)
    end

    describe "#total_male_participants" do
      it "returns the number of total male participants" do
        expect(stats.total_male_participants).to be 5
      end
    end

    describe "#total_female_participants" do
      it "returns the number of total female participants" do
        expect(stats.total_female_participants).to be 4
      end
    end

    describe "#total_other_participants" do
      it "returns the number of total other participants" do
        expect(stats.total_other_participants).to be 1
      end
    end

    describe "#male_percentage" do
      it "returns the percentage of male participants" do
        expect(stats.male_percentage).to be 50.0
      end
    end

    describe "#female_percentage" do
      it "returns the percentage of female participants" do
        expect(stats.female_percentage).to be 40.0
      end
    end

    describe "#other_percentage" do
      it "returns the percentage of other participants" do
        expect(stats.other_percentage).to be 10.0
      end
    end
  end

  describe "#participants_by_age" do
    before do
      [21, 22, 23, 23, 34, 42, 43, 44, 50, 51].each do |age|
        create(:user, date_of_birth: age.years.ago)
      end

      allow(stats).to receive(:participants).and_return(User.all)
    end

    it "returns the age groups hash" do
      expect(stats.participants_by_age["16 - 19"][:count]).to be 0
      expect(stats.participants_by_age["20 - 24"][:count]).to be 4
      expect(stats.participants_by_age["25 - 29"][:count]).to be 0
      expect(stats.participants_by_age["30 - 34"][:count]).to be 1
      expect(stats.participants_by_age["35 - 39"][:count]).to be 0
      expect(stats.participants_by_age["40 - 44"][:count]).to be 3
      expect(stats.participants_by_age["45 - 49"][:count]).to be 0
      expect(stats.participants_by_age["50 - 54"][:count]).to be 2
      expect(stats.participants_by_age["55 - 59"][:count]).to be 0
      expect(stats.participants_by_age["60 - 64"][:count]).to be 0
      expect(stats.participants_by_age["65 - 69"][:count]).to be 0
      expect(stats.participants_by_age["70 - 74"][:count]).to be 0
    end
  end

  describe "#headings" do
    before do
      investment.heading.update_column(:population, 1234)
      create(:budget_investment, heading: investment.heading)
      2.times { create(:vote, votable: investment) }
      create(:budget_ballot_line, investment: investment)
    end

    it "returns headings data" do
      heading_stats = stats.headings[investment.heading.id]
      expect(heading_stats[:total_investments_count]).to be 2
      expect(heading_stats[:total_participants_support_phase]).to be 2
      expect(heading_stats[:total_participants_vote_phase]).to be 1
      expect(heading_stats[:total_participants_every_phase]).to be 3
      expect(heading_stats[:percentage_participants_support_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_support_phase]).to be 0.162
      expect(heading_stats[:percentage_participants_vote_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_vote_phase]).to be 0.081
      expect(heading_stats[:percentage_participants_every_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_every_phase]).to be 0.243
    end
  end

  describe "#support_phase_finished?" do
    context "support phase isn't finished" do
      before { budget.phase = "selecting" }

      it "is false" do
        expect(stats.support_phase_finished?).to be false
      end
    end

    context "support phase is finished" do
      before { budget.phase = "valuating" }

      it "is false" do
        expect(stats.support_phase_finished?).to be true
      end
    end
  end

  describe "#vote_phase_finished" do
    context "support phase isn't finished" do
      before { budget.phase = "reviewing_ballots" }

      it "is false" do
        expect(stats.vote_phase_finished?).to be false
      end
    end

    context "vote phase is finished" do
      before { budget.phase = "finished" }

      it "is false" do
        expect(stats.vote_phase_finished?).to be true
      end
    end
  end

  describe "#all_phases" do
    context "no phases are finished" do
      before do
        allow(stats).to receive(:support_phase_finished?).and_return(false)
        allow(stats).to receive(:vote_phase_finished?).and_return(false)
      end

      it "returns an empty array" do
        expect(stats.all_phases).to eq []
      end
    end

    context "one phase is finished" do
      before do
        allow(stats).to receive(:support_phase_finished?).and_return(true)
        allow(stats).to receive(:vote_phase_finished?).and_return(false)
      end

      it "returns the finished phase" do
        expect(stats.all_phases).to eq ["support"]
      end
    end

    context "all phases are finished" do
      before do
        allow(stats).to receive(:support_phase_finished?).and_return(true)
        allow(stats).to receive(:vote_phase_finished?).and_return(true)
      end

      it "returns the finished phases and a total phase" do
        expect(stats.all_phases).to eq ["support", "vote", "every"]
      end
    end
  end
end
