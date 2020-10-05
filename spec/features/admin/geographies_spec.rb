require "rails_helper"

describe "Admin geographies" do
  let(:valid_geojson) do
    '{
       "geometry": {
         "type": "Polygon",
         "coordinates": [
           [40.9192937308316, -3.9259027239257],
           [40.9188966596619, -3.9239047078766],
           [40.9189131852224, -3.8947799675785]
         ]
       }
    }'
  end
  let(:invalid_geojson) do
    '{
       "geoADmetries": {
         "type": "Polygon",
         "crds": [
           [40.9192937308316, -3.9259027239257],
           [40.9188966596619, -3.9239047078766],
           [40.9189131852224, -3.8947799675785]
         ]
       }
    }'
  end

  before { login_as(create(:administrator).user) }

  scenario "Show names of geographies on index" do
    district_11 = create(:geography, name: "District 11", color: "#0081aa")
    district_12 = create(:geography, name: "District 12", color: "#0097aa")
    district_13 = create(:geography, name: "District 13", color: "#0063aa")

    visit admin_geographies_path

    expect(page).to have_content(district_11.name)
    expect(page).to have_content(district_12.name)
    expect(page).to have_content(district_13.name)
  end

  scenario 'Show "No related Headings" for geography without relate heading' do
    create(:geography, name: "District 11", color: "#0081aa")

    visit admin_geographies_path

    expect(page).to have_content("No related Headings")
  end

  scenario "Show Heading's names for geography with related headings" do
    group = create(:budget_group, :accepting_budget)
    heading_1 = create(:budget_heading, group: group)
    heading_2 = create(:budget_heading, group: group)

    create(:geography, name: "District 11", color: "#0081aa", headings: [heading_1, heading_2])

    visit admin_geographies_path

    expect(page).to have_content(heading_1.name_with_budget)
    expect(page).to have_content(heading_2.name_with_budget)
  end

  scenario "Create new geography" do
    heading_1 = create(:budget_heading)
    visit admin_root_path

    within("#side_menu") { click_link "Manage geographies" }

    click_link "Create geography"

    fill_in "geography_name", with: "District 11"
    fill_in "geography_geojson", with: valid_geojson
    select(heading_1.name_with_budget, from: "geography_heading_ids")

    click_button "Create Geography"
    expect(page).to have_content "Geography created successfully!"

    visit admin_geographies_path
    expect(page).to have_content "District 11"
  end

  scenario "Failed to create geography with incorrect geojson's file format" do
    visit admin_root_path

    within("#side_menu") { click_link "Manage geographies" }

    click_link "Create geography"

    fill_in "geography_name", with: "District 30"
    fill_in "geography_geojson", with: invalid_geojson

    click_button "Create Geography"

    expect(page).not_to have_content "Geography created successfully!"
    expect(page).to have_css(".is-invalid-label", text: "Geojson")
    expect(page).to have_css("small.form-error", text: "The GeoJSON provided does not follow the correct format. " \
                                                       'It must follow the "Polygon" or "MultiPolygon" type format.')
  end

  scenario "Edit geography with no associated headings" do
    geography = create(:geography, name: "Edit me!", color: "#0097aa")

    visit admin_geographies_path

    within("#geography_#{geography.id}") { click_link "Edit" }

    fill_in "geography_name", with: "New geography name"

    click_button "Update Geography"
    expect(page).to have_content "Geography updated successfully!"

    within("#geography_#{geography.id}") do
      expect(page).to have_content "New geography name"
    end
  end

  scenario "Edit geography with associated headings" do
    heading_1 = create(:budget_heading)
    geography = create(:geography, name: "Delete me!", color: "#0088aa", headings: [heading_1])

    visit admin_geographies_path

    within("#geography_#{geography.id}") { click_link "Edit" }

    fill_in "geography_name", with: "New geography name"

    click_button "Update Geography"
    expect(page).to have_content "Geography updated successfully!"

    within("#geography_#{geography.id}") do
      expect(page).to have_content "New geography name"
    end
  end

  scenario "Failed to edit geography filling incorrect geojson's file format" do
    geography = create(:geography, name: "Delete me!", color: "#0088aa")

    visit admin_geographies_path

    within("#geography_#{geography.id}") { click_link "Edit" }

    fill_in "geography_geojson", with: invalid_geojson

    click_button "Update Geography"

    expect(page).not_to have_content "Geography updated successfully!"
    expect(page).to have_css(".is-invalid-label", text: "Geojson")
    expect(page).to have_css("small.form-error", text: "The GeoJSON provided does not follow the correct format. " \
                                                       'It must follow the "Polygon" or "MultiPolygon" type format.')
  end

  scenario "Delete geography with no associated headings" do
    geography = create(:geography, name: "Delete me!", color: "#0097aa")

    visit admin_geographies_path

    expect(page).to have_content("Delete me!")

    within("#geography_#{geography.id}") { click_link "Delete" }

    expect(page).to have_content "Geography deleted successfully!"
    expect(page).not_to have_content("Delete me!")
    expect(Geography.where(id: geography.id)).to be_empty
  end

  scenario "Delete geography with associated headings" do
    heading_1 = create(:budget_heading)
    geography = create(:geography, name: "Delete me!", color: "#0122ab", headings: [heading_1])

    visit admin_geographies_path

    expect(page).to have_content("Delete me!")
    expect(page).to have_content(heading_1.name_with_budget)

    within("#geography_#{geography.id}") { click_link "Delete" }

    expect(page).to have_content "Geography deleted successfully!"
    expect(page).not_to have_content("Delete me!")
    expect(page).not_to have_content(heading_1.name_with_budget)
    expect(Geography.where(id: geography.id)).to be_empty
  end
end
