require "rails_helper"

describe Geography do
  let(:geography) { build(:geography) }

  it "is valid" do
    expect(geography).to be_valid
  end

  it "is not valid without a name" do
    geography.name = nil
    expect(geography).not_to be_valid
  end

  it "is not valid without a color" do
    geography.color = nil
    expect(geography).not_to be_valid
  end

  it "is not valid without correct geojson's file format" do
    invalid_geography = build(:geography,
                               geojson: '{"geo\":{"type":"Incorrect key","coordinates":
                                                [[40.8792937308316, -3.9259027239257],
                                                [40.8788966596619, -3.9249047078766],
                                                [40.8789131852224, -3.9247799675785]]}}')
    expect(invalid_geography).not_to be_valid
  end

  describe "budget heading dependency" do
    it "is true when deleting geography not linked to budget headings" do
      geography = create(:geography)

      expect do
        geography.destroy
      end.to change { Geography.count }.by(-1)
    end

    it "is true deleting geography, even when linked to one budget heading" do
      geography_with_one_related_heading = create(:geography, :with_one_related_heading)

      expect do
        geography_with_one_related_heading.destroy
      end.to change { Geography.count }.by(-1)
    end

    it "is true deleting geography, even when linked to many budget headings" do
      geography_with_many_related_headings = create(:geography, :with_many_related_headings)

      expect do
        geography_with_many_related_headings.destroy
      end.to change { Geography.count }.by(-1)
    end
  end

  describe "#parsed_outline_points" do
    it "returns empty array when geojson is nil" do
      expect(geography.parsed_outline_points).to eq([])
    end

    it "returns coordinates array when geojson is not nil" do
      geography_with_ouline_points = build(:geography, :with_geojson_coordinates)
      expect(geography_with_ouline_points.parsed_outline_points).to eq(
        [[-3.9259027239257, 40.8792937308316],
        [-3.9249047078766, 40.8788966596619],
        [-3.9247799675785, 40.8789131852224]])
    end
  end

  describe "#for_current_budget" do
    it "returns empty array if no active geographies" do
      create(:geography)
      expect(Geography.for_current_budget).to be_empty
    end

    it "returns all active geographies" do
      active_group = create(:budget_group, :accepting_budget)
      drafting_group = create(:budget_group, :drafting_budget)

      active_heading_1 = create(:budget_heading, group: active_group)
      active_heading_2 = create(:budget_heading, group: active_group)
      active_heading_3 = create(:budget_heading, group: active_group)
      active_heading_4 = create(:budget_heading, group: active_group)
      not_active_heading_1 = create(:budget_heading, group: drafting_group)
      not_active_heading_2 = create(:budget_heading, group: drafting_group)

      active_geography_1 = create(:geography, headings: [active_heading_1, not_active_heading_1])
      active_geography_2 = create(:geography, headings: [active_heading_2])
      active_geography_3 = create(:geography, headings: [active_heading_3])
      active_geography_4 = create(:geography, headings: [active_heading_4])
      not_active_geography = create(:geography, headings: [not_active_heading_2])

      expect(Geography.for_current_budget.size).to be 4
      expect(Geography.for_current_budget).to include active_geography_1
      expect(Geography.for_current_budget).to include active_geography_2
      expect(Geography.for_current_budget).to include active_geography_3
      expect(Geography.for_current_budget).to include active_geography_4
      expect(Geography.for_current_budget).not_to include not_active_geography
    end
  end
end
