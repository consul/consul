require "rails_helper"

describe "Admin moderators", :admin do
  let!(:user)      { create(:user, username: "Jose Luis Balbin") }
  let!(:moderator) { create(:moderator) }

  scenario "Index" do
    visit admin_moderators_path

    expect(page).to have_content moderator.name
    expect(page).to have_content moderator.email
    expect(page).not_to have_content user.name
  end

  scenario "Create Moderator" do
    visit admin_moderators_path

    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content user.name
    click_link "Add"
    within("#moderators") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete Moderator" do
    visit admin_moderators_path

    accept_confirm("Delete: Are you sure?") { click_link "Delete" }

    within("#moderators") do
      expect(page).not_to have_content moderator.name
    end
  end

  context "Search" do
    let(:user)        { create(:user, username: "Elizabeth Bathory", email: "elizabeth@bathory.com") }
    let(:user2)       { create(:user, username: "Ada Lovelace", email: "ada@lovelace.com") }
    let!(:moderator1) { create(:moderator, user: user) }
    let!(:moderator2) { create(:moderator, user: user2) }

    before do
      visit admin_moderators_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(moderator1.name)
      expect(page).to have_content(moderator2.name)

      fill_in "search", with: " "
      click_button "Search"

      expect(page).to have_content("Moderators: User search")
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(moderator1.name)
      expect(page).not_to have_content(moderator2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(moderator1.name)
      expect(page).to have_content(moderator2.name)

      fill_in "search", with: "Eliz"
      click_button "Search"

      expect(page).to have_content("Moderators: User search")
      expect(page).to have_field "search", with: "Eliz"
      expect(page).to have_content(moderator1.name)
      expect(page).not_to have_content(moderator2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(moderator1.email)
      expect(page).to have_content(moderator2.email)

      fill_in "search", with: moderator2.email
      click_button "Search"

      expect(page).to have_content("Moderators: User search")
      expect(page).to have_field "search", with: moderator2.email
      expect(page).to have_content(moderator2.email)
      expect(page).not_to have_content(moderator1.email)
    end

    scenario "Delete after searching" do
      fill_in "Search user by name or email", with: moderator2.email
      click_button "Search"

      accept_confirm("Delete: Are you sure?") { click_link "Delete" }

      expect(page).to have_content(moderator1.email)
      expect(page).not_to have_content(moderator2.email)
    end
  end
end
