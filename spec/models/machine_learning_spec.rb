require "rails_helper"

describe MachineLearning do
  def full_sanitizer(string)
    ActionView::Base.full_sanitizer.sanitize(string)
  end

  let(:job) { create :machine_learning_job }

  describe "#cleanup_proposals_tags!" do
    it "does not delete other machine learning generated data" do
      create :ml_summary_comment, commentable: create(:proposal)
      create :ml_summary_comment, commentable: create(:budget_investment)

      create :related_content, :proposals, :from_machine_learning
      create :related_content, :budget_investments, :from_machine_learning

      expect(MlSummaryComment.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_proposals_tags!)

      expect(MlSummaryComment.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2
    end

    it "deletes proposals tags machine learning generated data" do
      user_tag = create(:tag)
      create(:tagging, tag: user_tag)

      ml_proposal_tag = create(:tag)
      create(:tagging, tag: ml_proposal_tag, context: "ml_proposal_tags")

      ml_investment_tag = create(:tag)
      create(:tagging, tag: ml_investment_tag, context: "ml_investment_tags")

      common_tag = create(:tag)
      create(:tagging, tag: common_tag)
      create(:tagging, tag: common_tag, context: "ml_proposal_tags")
      create(:tagging, tag: common_tag, context: "ml_investment_tags")

      expect(Tag.count).to be 4
      expect(Tagging.count).to be 6
      expect(Tagging.where(context: "tags").count).to be 2
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 2
      expect(Tagging.where(context: "ml_investment_tags").count).to be 2

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_proposals_tags!)

      expect(Tag.count).to be 3
      expect(Tag.all).not_to include ml_proposal_tag
      expect(Tagging.count).to be 4
      expect(Tagging.where(context: "tags").count).to be 2
      expect(Tagging.where(context: "ml_proposal_tags")).to be_empty
      expect(Tagging.where(context: "ml_investment_tags").count).to be 2
    end
  end

  describe "#cleanup_investments_tags!" do
    it "does not delete other machine learning generated data" do
      create :ml_summary_comment, commentable: create(:proposal)
      create :ml_summary_comment, commentable: create(:budget_investment)

      create :related_content, :proposals, :from_machine_learning
      create :related_content, :budget_investments, :from_machine_learning

      expect(MlSummaryComment.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_investments_tags!)

      expect(MlSummaryComment.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2
    end

    it "deletes investments tags machine learning generated data" do
      user_tag = create(:tag)
      create(:tagging, tag: user_tag)

      ml_proposal_tag = create(:tag)
      create(:tagging, tag: ml_proposal_tag, context: "ml_proposal_tags")

      ml_investment_tag = create(:tag)
      create(:tagging, tag: ml_investment_tag, context: "ml_investment_tags")

      common_tag = create(:tag)
      create(:tagging, tag: common_tag)
      create(:tagging, tag: common_tag, context: "ml_proposal_tags")
      create(:tagging, tag: common_tag, context: "ml_investment_tags")

      expect(Tag.count).to be 4
      expect(Tagging.count).to be 6
      expect(Tagging.where(context: "tags").count).to be 2
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 2
      expect(Tagging.where(context: "ml_investment_tags").count).to be 2

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_investments_tags!)

      expect(Tag.count).to be 3
      expect(Tag.all).not_to include ml_investment_tag
      expect(Tagging.count).to be 4
      expect(Tagging.where(context: "tags").count).to be 2
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 2
      expect(Tagging.where(context: "ml_investment_tags")).to be_empty
    end
  end

  describe "#cleanup_proposals_related_content!" do
    it "does not delete other machine learning generated data" do
      create :ml_summary_comment, commentable: create(:proposal)
      create :ml_summary_comment, commentable: create(:budget_investment)

      create(:tagging, tag: create(:tag))
      create(:tagging, tag: create(:tag), context: "ml_proposal_tags")
      create(:tagging, tag: create(:tag), context: "ml_investment_tags")

      expect(MlSummaryComment.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_proposals_related_content!)

      expect(MlSummaryComment.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1
    end

    it "deletes proposals related content machine learning generated data" do
      create :related_content, :proposals
      create :related_content, :budget_investments
      create :related_content, :proposals, :from_machine_learning
      create :related_content, :budget_investments, :from_machine_learning

      expect(RelatedContent.for_proposals.from_users.count).to be 2
      expect(RelatedContent.for_investments.from_users.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_proposals_related_content!)

      expect(RelatedContent.for_proposals.from_users.count).to be 2
      expect(RelatedContent.for_investments.from_users.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning).to be_empty
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2
    end
  end

  describe "#cleanup_investments_related_content!" do
    it "does not delete other machine learning generated data" do
      create :ml_summary_comment, commentable: create(:proposal)
      create :ml_summary_comment, commentable: create(:budget_investment)

      create(:tagging, tag: create(:tag))
      create(:tagging, tag: create(:tag), context: "ml_proposal_tags")
      create(:tagging, tag: create(:tag), context: "ml_investment_tags")

      expect(MlSummaryComment.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_investments_related_content!)

      expect(MlSummaryComment.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1
    end

    it "deletes proposals related content machine learning generated data" do
      create :related_content, :proposals
      create :related_content, :budget_investments
      create :related_content, :proposals, :from_machine_learning
      create :related_content, :budget_investments, :from_machine_learning

      expect(RelatedContent.for_proposals.from_users.count).to be 2
      expect(RelatedContent.for_investments.from_users.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_investments_related_content!)

      expect(RelatedContent.for_proposals.from_users.count).to be 2
      expect(RelatedContent.for_investments.from_users.count).to be 2
      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning).to be_empty
    end
  end

  describe "#cleanup_proposals_comments_summary!" do
    it "does not delete other machine learning generated data" do
      create :related_content, :proposals, :from_machine_learning
      create :related_content, :budget_investments, :from_machine_learning

      create(:tagging, tag: create(:tag))
      create(:tagging, tag: create(:tag), context: "ml_proposal_tags")
      create(:tagging, tag: create(:tag), context: "ml_investment_tags")

      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_proposals_comments_summary!)

      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1
    end

    it "deletes proposals comments summary machine learning generated data" do
      create :ml_summary_comment, commentable: create(:proposal)
      create :ml_summary_comment, commentable: create(:budget_investment)

      expect(MlSummaryComment.where(commentable_type: "Proposal").count).to be 1
      expect(MlSummaryComment.where(commentable_type: "Budget::Investment").count).to be 1

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_proposals_comments_summary!)

      expect(MlSummaryComment.where(commentable_type: "Proposal")).to be_empty
      expect(MlSummaryComment.where(commentable_type: "Budget::Investment").count).to be 1
    end
  end

  describe "#cleanup_investments_comments_summary!" do
    it "does not delete other machine learning generated data" do
      create :related_content, :proposals, :from_machine_learning
      create :related_content, :budget_investments, :from_machine_learning

      create(:tagging, tag: create(:tag))
      create(:tagging, tag: create(:tag), context: "ml_proposal_tags")
      create(:tagging, tag: create(:tag), context: "ml_investment_tags")

      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_investments_comments_summary!)

      expect(RelatedContent.for_proposals.from_machine_learning.count).to be 2
      expect(RelatedContent.for_investments.from_machine_learning.count).to be 2
      expect(Tag.count).to be 3
      expect(Tagging.count).to be 3
      expect(Tagging.where(context: "tags").count).to be 1
      expect(Tagging.where(context: "ml_proposal_tags").count).to be 1
      expect(Tagging.where(context: "ml_investment_tags").count).to be 1
    end

    it "deletes budget investments comments summary machine learning generated data" do
      create :ml_summary_comment, commentable: create(:proposal)
      create :ml_summary_comment, commentable: create(:budget_investment)

      expect(MlSummaryComment.where(commentable_type: "Proposal").count).to be 1
      expect(MlSummaryComment.where(commentable_type: "Budget::Investment").count).to be 1

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:cleanup_investments_comments_summary!)

      expect(MlSummaryComment.where(commentable_type: "Proposal").count).to be 1
      expect(MlSummaryComment.where(commentable_type: "Budget::Investment")).to be_empty
    end
  end

  describe "#export_proposals_to_json" do
    it "creates a JSON file with all proposals" do
      require "fileutils"
      FileUtils.mkdir_p Rails.root.join("public", "machine_learning", "data")

      first_proposal = create :proposal
      last_proposal = create :proposal

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:export_proposals_to_json)

      json_file = MachineLearning::DATA_FOLDER.join("proposals.json")
      json = JSON.parse(File.read(json_file))

      expect(json).to be_an Array
      expect(json.size).to be 2

      expect(json.first["id"]).to eq first_proposal.id
      expect(json.first["title"]).to eq first_proposal.title
      expect(json.first["summary"]).to eq full_sanitizer(first_proposal.summary)
      expect(json.first["description"]).to eq full_sanitizer(first_proposal.description)

      expect(json.last["id"]).to eq last_proposal.id
      expect(json.last["title"]).to eq last_proposal.title
      expect(json.last["summary"]).to eq full_sanitizer(last_proposal.summary)
      expect(json.last["description"]).to eq full_sanitizer(last_proposal.description)
    end
  end

  describe "#export_budget_investments_to_json" do
    it "creates a JSON file with all budget investments" do
      require "fileutils"
      FileUtils.mkdir_p Rails.root.join("public", "machine_learning", "data")

      first_budget_investment = create :budget_investment
      last_budget_investment = create :budget_investment

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:export_budget_investments_to_json)

      json_file = MachineLearning::DATA_FOLDER.join("budget_investments.json")
      json = JSON.parse(File.read(json_file))

      expect(json).to be_an Array
      expect(json.size).to be 2

      expect(json.first["id"]).to eq first_budget_investment.id
      expect(json.first["title"]).to eq first_budget_investment.title
      expect(json.first["description"]).to eq full_sanitizer(first_budget_investment.description)

      expect(json.last["id"]).to eq last_budget_investment.id
      expect(json.last["title"]).to eq last_budget_investment.title
      expect(json.last["description"]).to eq full_sanitizer(last_budget_investment.description)
    end
  end

  describe "#export_comments_to_json" do
    it "creates a JSON file with all comments" do
      require "fileutils"
      FileUtils.mkdir_p Rails.root.join("public", "machine_learning", "data")

      first_comment = create :comment
      last_comment = create :comment

      machine_learning = MachineLearning.new(job)
      machine_learning.send(:export_comments_to_json)

      json_file = MachineLearning::DATA_FOLDER.join("comments.json")
      json = JSON.parse(File.read(json_file))

      expect(json).to be_an Array
      expect(json.size).to be 2

      expect(json.first["id"]).to eq first_comment.id
      expect(json.first["commentable_id"]).to eq first_comment.commentable_id
      expect(json.first["commentable_type"]).to eq first_comment.commentable_type
      expect(json.first["body"]).to eq full_sanitizer(first_comment.body)

      expect(json.last["id"]).to eq last_comment.id
      expect(json.last["commentable_id"]).to eq last_comment.commentable_id
      expect(json.last["commentable_type"]).to eq last_comment.commentable_type
      expect(json.last["body"]).to eq full_sanitizer(last_comment.body)
    end
  end

  describe "#run_machine_learning_scripts" do
    it "returns true if python script executed correctly" do
      machine_learning = MachineLearning.new(job)

      command = "cd #{MachineLearning::SCRIPTS_FOLDER} && python script.py 2>&1"
      expect(machine_learning).to receive(:`).with(command) do
        Process.waitpid Process.fork { exit 0 }
      end

      expect(Mailer).not_to receive(:machine_learning_error)

      expect(machine_learning.send(:run_machine_learning_scripts)).to be true

      job.reload
      expect(job.finished_at).not_to be_present
      expect(job.error).not_to be_present
    end

    it "returns false if python script errored" do
      machine_learning = MachineLearning.new(job)

      command = "cd #{MachineLearning::SCRIPTS_FOLDER} && python script.py 2>&1"
      expect(machine_learning).to receive(:`).with(command) do
        Process.waitpid Process.fork { abort "error message" }
      end

      mailer = double("mailer")
      expect(mailer).to receive(:deliver_later)
      expect(Mailer).to receive(:machine_learning_error).and_return mailer

      expect(machine_learning.send(:run_machine_learning_scripts)).to be false

      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).not_to eq "error message"
    end
  end

  describe "#import_ml_proposals_comments_summary" do
    it "feeds the database using content from the JSON file generated by the machine learning script" do
      machine_learning = MachineLearning.new(job)

      proposal = create :proposal

      data = [
        { commentable_id: proposal.id,
          commentable_type: "Proposal",
          body: "Summary comment for proposal with ID #{proposal.id}" }
      ]

      filename = "ml_comments_summaries_proposals.json"
      json_file = MachineLearning::DATA_FOLDER.join(filename)
      expect(File).to receive(:read).with(json_file).and_return data.to_json

      machine_learning.send(:import_ml_proposals_comments_summary)

      expect(proposal.summary_comment.body).to eq "Summary comment for proposal with ID #{proposal.id}"
    end
  end

  describe "#import_ml_investments_comments_summary" do
    it "feeds the database using content from the JSON file generated by the machine learning script" do
      machine_learning = MachineLearning.new(job)

      investment = create :budget_investment

      data = [
        { commentable_id: investment.id,
          commentable_type: "Budget::Investment",
          body: "Summary comment for investment with ID #{investment.id}" }
      ]

      filename = "ml_comments_summaries_budgets.json"
      json_file = MachineLearning::DATA_FOLDER.join(filename)
      expect(File).to receive(:read).with(json_file).and_return data.to_json

      machine_learning.send(:import_ml_investments_comments_summary)

      expect(investment.summary_comment.body).to eq "Summary comment for investment with ID #{investment.id}"
    end
  end

  describe "#import_proposals_related_content" do
    it "feeds the database using content from the JSON file generated by the machine learning script" do
      machine_learning = MachineLearning.new(job)

      proposal = create :proposal
      related_proposal = create :proposal
      other_related_proposal = create :proposal

      data = [
        {
          "id" => proposal.id,
          "related1" => related_proposal.id,
          "related2" => other_related_proposal.id
        }
      ]

      filename = "ml_related_content_proposals.json"
      json_file = MachineLearning::DATA_FOLDER.join(filename)
      expect(File).to receive(:read).with(json_file).and_return data.to_json

      machine_learning.send(:import_proposals_related_content)

      expect(proposal.related_contents.count).to be 2
      expect(proposal.related_contents.first.child_relationable).to eq related_proposal
      expect(proposal.related_contents.last.child_relationable).to eq other_related_proposal
    end
  end

  describe "#import_budget_investments_related_content" do
    it "feeds the database using content from the JSON file generated by the machine learning script" do
      machine_learning = MachineLearning.new(job)

      investment = create :budget_investment
      related_investment = create :budget_investment
      other_related_investment = create :budget_investment

      data = [
        {
          "id" => investment.id,
          "related1" => related_investment.id,
          "related2" => other_related_investment.id
        }
      ]

      filename = "ml_related_content_budgets.json"
      json_file = MachineLearning::DATA_FOLDER.join(filename)
      expect(File).to receive(:read).with(json_file).and_return data.to_json

      machine_learning.send(:import_budget_investments_related_content)

      expect(investment.related_contents.count).to be 2
      expect(investment.related_contents.first.child_relationable).to eq related_investment
      expect(investment.related_contents.last.child_relationable).to eq other_related_investment
    end
  end

  describe "#import_ml_proposals_tags" do
    it "feeds the database using content from the JSON file generated by the machine learning script" do
      create :tag, name: "Existing tag"
      proposal = create :proposal
      machine_learning = MachineLearning.new(job)

      tags_data = [
        { id: 0,
          name: "Existing tag" },
        { id: 1,
          name: "Machine learning tag" }
      ]

      taggings_data = [
        { tag_id: 0,
          taggable_id: proposal.id
        },
        { tag_id: 1,
          taggable_id: proposal.id
        }
      ]

      tags_filename = "ml_tags_proposals.json"
      tags_json_file = MachineLearning::DATA_FOLDER.join(tags_filename)
      expect(File).to receive(:read).with(tags_json_file).and_return tags_data.to_json

      taggings_filename = "ml_taggings_proposals.json"
      taggings_json_file = MachineLearning::DATA_FOLDER.join(taggings_filename)
      expect(File).to receive(:read).with(taggings_json_file).and_return taggings_data.to_json

      machine_learning.send(:import_ml_proposals_tags)

      expect(Tag.count).to be 2
      expect(Tag.first.name).to eq "Existing tag"
      expect(Tag.last.name).to eq "Machine learning tag"
      expect(proposal.tags).to be_empty
      expect(proposal.ml_proposal_tags.count).to be 2
      expect(proposal.ml_proposal_tags.first.name).to eq "Existing tag"
      expect(proposal.ml_proposal_tags.last.name).to eq "Machine learning tag"
    end
  end

  describe "#import_ml_investments_tags" do
    it "feeds the database using content from the JSON file generated by the machine learning script" do
      create :tag, name: "Existing tag"
      investment = create :budget_investment
      machine_learning = MachineLearning.new(job)

      tags_data = [
        { id: 0,
          name: "Existing tag" },
        { id: 1,
          name: "Machine learning tag" }
      ]

      taggings_data = [
        { tag_id: 0,
          taggable_id: investment.id
        },
        { tag_id: 1,
          taggable_id: investment.id
        }
      ]

      tags_filename = "ml_tags_budgets.json"
      tags_json_file = MachineLearning::DATA_FOLDER.join(tags_filename)
      expect(File).to receive(:read).with(tags_json_file).and_return tags_data.to_json

      taggings_filename = "ml_taggings_budgets.json"
      taggings_json_file = MachineLearning::DATA_FOLDER.join(taggings_filename)
      expect(File).to receive(:read).with(taggings_json_file).and_return taggings_data.to_json

      machine_learning.send(:import_ml_investments_tags)

      expect(Tag.count).to be 2
      expect(Tag.first.name).to eq "Existing tag"
      expect(Tag.last.name).to eq "Machine learning tag"
      expect(investment.tags).to be_empty
      expect(investment.ml_investment_tags.count).to be 2
      expect(investment.ml_investment_tags.first.name).to eq "Existing tag"
      expect(investment.ml_investment_tags.last.name).to eq "Machine learning tag"
    end
  end
end
