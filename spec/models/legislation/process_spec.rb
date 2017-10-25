require 'rails_helper'

RSpec.describe Legislation::Process, type: :model do
  let(:process) { create(:legislation_process) }

  it_behaves_like "a class with phase", :debate, :debate_start_date, :debate_end_date, :debate_phase_enabled
  it_behaves_like "a class with phase", :allegations, :allegations_start_date, :allegations_end_date, :allegations_phase_enabled
  it_behaves_like "a class with phase", :global, :start_date, :end_date, :published
  it_behaves_like "a class with publication", :draft, :draft_publication_date, :draft_publication_enabled
  it_behaves_like "a class with publication", :result, :result_publication_date, :result_publication_enabled

  it "should be valid" do
    expect(process).to be_valid
  end
end
