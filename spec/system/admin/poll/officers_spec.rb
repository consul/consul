require "rails_helper"

describe "Admin poll officers", :admin do
  let!(:user)    { create(:user, username: "Pedro Jose Garcia") }
  let!(:officer) { create(:poll_officer) }

  before do
    visit admin_officers_path
  end

  scenario "Index" do
    expect(page).to have_content officer.name
    expect(page).to have_content officer.email
    expect(page).not_to have_content user.name
  end

  scenario "Create" do
    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content user.name
    click_link "Add"
    within("#officers") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete" do
    accept_confirm("Delete position: Are you sure?") { click_link "Delete position" }

    expect(page).not_to have_css "#officers"
  end
end
