require "rails_helper"

describe Legislation::Process do
  let(:process) { create(:legislation_process) }

  it "is valid" do
    expect(process).to be_valid
  end

  describe "dates validations" do
    it "is invalid if debate_start_date is present but debate_end_date is not" do
      process = build(:legislation_process, debate_start_date: Date.current, debate_end_date: "")
      expect(process).to be_invalid
      expect(process.errors.messages[:debate_end_date]).to include("can't be blank")
    end

    it "is invalid if debate_end_date is present but debate_start_date is not" do
      process = build(:legislation_process, debate_start_date: nil, debate_end_date: Date.current)
      expect(process).to be_invalid
      expect(process.errors.messages[:debate_start_date]).to include("can't be blank")
    end

    it "is invalid if allegations_start_date is present but debate_end_date is not" do
      process = build(:legislation_process, allegations_start_date: Date.current,
                                            allegations_end_date: "")
      expect(process).to be_invalid
      expect(process.errors.messages[:allegations_end_date]).to include("can't be blank")
    end

    it "is invalid if debate_end_date is present but allegations_start_date is not" do
      process = build(:legislation_process, allegations_start_date: nil,
                                            allegations_end_date: Date.current)
      expect(process).to be_invalid
      expect(process.errors.messages[:allegations_start_date]).to include("can't be blank")
    end
  end

  describe "date ranges validations" do
    it "is invalid if end_date is before start_date" do
      process = build(:legislation_process, start_date: Date.current,
                                            end_date: Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:end_date]).to include("must be on or after the start date")
    end

    it "is valid if end_date is the same as start_date" do
      process = build(:legislation_process, start_date: Date.current - 1.day,
                                            end_date: Date.current - 1.day)
      expect(process).to be_valid
    end

    it "is valid if debate_end_date is the same as debate_start_date" do
      process = build(:legislation_process, debate_start_date: Date.current - 1.day,
                                            debate_end_date: Date.current - 1.day)
      expect(process).to be_valid
    end

    it "is invalid if debate_end_date is before debate_start_date" do
      process = build(:legislation_process, debate_start_date: Date.current,
                                            debate_end_date: Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:debate_end_date])
      .to include("must be on or after the debate start date")
    end

    it "is valid if draft_end_date is the same as draft_start_date" do
      process = build(:legislation_process, draft_start_date: Date.current - 1.day,
                                            draft_end_date: Date.current - 1.day)
      expect(process).to be_valid
    end

    it "is invalid if draft_end_date is before draft_start_date" do
      process = build(:legislation_process, draft_start_date: Date.current,
                                            draft_end_date: Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:draft_end_date])
      .to include("must be on or after the draft start date")
    end

    it "is invalid if allegations_end_date is before allegations_start_date" do
      process = build(:legislation_process, allegations_start_date: Date.current,
                                            allegations_end_date: Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:allegations_end_date])
      .to include("must be on or after the comments start date")
    end

    it "is valid if allegations_end_date is the same as allegations_start_date" do
      process = build(:legislation_process, allegations_start_date: Date.current - 1.day,
                                              allegations_end_date: Date.current - 1.day)
      expect(process).to be_valid
    end
  end

  describe "filter scopes" do
    let!(:process_1) { create(:legislation_process, start_date: Date.current - 2.days,
                                                   end_date: Date.current + 1.day) }
    let!(:process_2) { create(:legislation_process, start_date: Date.current + 1.day,
                                              end_date: Date.current + 3.days) }
    let!(:process_3) { create(:legislation_process, start_date: Date.current - 4.days,
                                              end_date: Date.current - 3.days) }

    it "filters open" do
      open_processes = ::Legislation::Process.open

      expect(open_processes).to include(process_1)
      expect(open_processes).not_to include(process_2)
      expect(open_processes).not_to include(process_3)
    end

    it "filters draft phase" do
      process_before_draft = create(
        :legislation_process,
        draft_start_date: Date.current - 3.days,
        draft_end_date: Date.current - 2.days
      )

      process_with_draft_disabled = create(
        :legislation_process,
        draft_start_date: Date.current - 2.days,
        draft_end_date: Date.current + 2.days,
        draft_phase_enabled: false
      )

      process_with_draft_enabled = create(
        :legislation_process,
        draft_start_date: Date.current - 2.days,
        draft_end_date: Date.current + 2.days,
        draft_phase_enabled: true
      )

      process_with_draft_only_today = create(
        :legislation_process,
        draft_start_date: Date.current,
        draft_end_date: Date.current,
        draft_phase_enabled: true
      )

      processes_not_in_draft = ::Legislation::Process.not_in_draft

      expect(processes_not_in_draft).to include(process_before_draft)
      expect(processes_not_in_draft).to include(process_with_draft_disabled)
      expect(processes_not_in_draft).not_to include(process_with_draft_enabled)
      expect(processes_not_in_draft).not_to include(process_with_draft_only_today)
    end

    it "filters past" do
      past_processes = ::Legislation::Process.past

      expect(past_processes).to include(process_3)
      expect(past_processes).not_to include(process_2)
      expect(past_processes).not_to include(process_1)
    end
  end

  describe "#status" do
    it "detects planned phase" do
      process.update_attributes(start_date: Date.current + 2.days)
      expect(process.status).to eq(:planned)
    end

    it "detects closed phase" do
      process.update_attributes(end_date: Date.current - 2.days)
      expect(process.status).to eq(:closed)
    end

    it "detects open phase" do
      expect(process.status).to eq(:open)
    end
  end

  describe "Header colors" do
    it "valid format colors" do
      process1 = create(:legislation_process, background_color: "123", font_color: "#fff")
      process2 = create(:legislation_process, background_color: "#fff", font_color: "123")
      process3 = create(:legislation_process, background_color: "", font_color: "")
      process4 = create(:legislation_process, background_color: "#abf123", font_color: "fff123")
      expect(process1).to be_valid
      expect(process2).to be_valid
      expect(process3).to be_valid
      expect(process4).to be_valid
    end

    it "invalid format colors" do
      expect {
        process = create(:legislation_process, background_color: "#123ghi", font_color: "#fff")
      }.to raise_error(ActiveRecord::RecordInvalid,
                       "Validation failed: Background color is invalid")

      expect {
        process = create(:legislation_process, background_color: "#fff", font_color: "ggg")
      }.to raise_error(ActiveRecord::RecordInvalid,
                       "Validation failed: Font color is invalid")
    end
  end

  describe "proposal fields" do
    it "is valid when label is nil but it is not enabled" do
      process = build(:legislation_process,
                       description_enabled: false,
                       description_label: nil,
                       video_url_enabled: false,
                       video_url_label: nil,
                       image_enabled: false,
                       image_label: nil,
                       documents_enabled: false,
                       documents_label: nil,
                       geozone_enabled: false,
                       geozone_label: nil,
                       tags_enabled: false,
                       tags_label: nil)
      expect(process).to be_valid
    end
  end
end
