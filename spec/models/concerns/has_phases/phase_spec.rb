require 'rails_helper'

RSpec.describe HasPhases::Phase, type: :model do
  let(:future_phase) { build(:has_phases_phase) }
  let(:disabled_phase) { build(:has_phases_phase, enabled: false) }
  let(:started_phase) { build(:has_phases_phase, :past_start_date) }
  let(:finished_phase) { build(:has_phases_phase, :past_start_date, :past_end_date) }
  let(:invalid_phase) { build(:has_phases_phase, start_date: Date.current + 1.day, end_date: Date.current - 1.day) }
  let(:future_publication) { build(:has_phases_phase, :publication) }
  let(:disabled_publication) { build(:has_phases_phase, :publication, enabled: false) }
  let(:started_publication) { build(:has_phases_phase, :publication, :past_start_date) }

  describe "#enabled?" do
    it "is enabled" do
      [future_phase, future_publication].each do |phase|
        expect(phase.enabled?).to be true
      end
    end

    it "is disabled" do
      [disabled_phase, disabled_publication].each do |phase|
        expect(phase.enabled?).to be false
      end
    end
  end

  describe "#started?" do
    it "is started" do
      [started_phase, finished_phase, started_publication].each do |phase|
        expect(phase.started?).to be true
      end
    end

    it "is not started" do
      [future_phase, future_publication, disabled_phase, disabled_publication].each do |phase|
        expect(phase.started?).to be false
      end
    end
  end

  describe "#open?" do
    it "is open" do
      [started_phase, started_publication].each do |phase|
        expect(phase.open?).to be true
      end
    end

    it "is not opened" do
      [future_phase, disabled_phase, finished_phase, future_publication, disabled_publication].each do |phase|
        expect(phase.open?).to be false
      end
    end
  end

  describe "#end_date?" do
    it "is true for phases" do
      [future_phase, disabled_phase, started_phase, finished_phase, invalid_phase].each do |phase|
        expect(phase.end_date?).to be true
      end
    end

    it "is false for publications" do
      [future_publication, disabled_publication, started_publication].each do |phase|
        expect(phase.end_date?).to be false
      end
    end
  end

  describe "#valid?" do
    it "is valid if at least one of start_date or end_date is not present" do
      expect(future_publication.valid?).to be true
      expect(build(:has_phases_phase, start_date: nil).valid?).to be true
    end

    it "is invalid when start and end dates are present and end is before start" do
      expect(invalid_phase.valid?).to be false
    end
  end

  describe "#status" do
    it "future phase" do
      expect(future_phase.status).to eq :planned
    end

    it "started phase" do
      expect(started_phase.status).to eq :open
    end

    it "finished phase" do
      expect(finished_phase.status).to eq :closed
    end

    it "future publication" do
      expect(future_publication.status).to eq :planned
    end

    it "started publication" do
      expect(started_publication.status).to eq :open
    end
  end

end
