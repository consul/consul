require "rails_helper"

describe "Admin managers", :admin do
  let!(:user) { create(:user) }
  let!(:manager) { create(:manager) }

  scenario "Index" do
    visit admin_managers_path

    expect(page).to have_content manager.name
    expect(page).to have_content manager.email
    expect(page).not_to have_content user.name
  end

  scenario "Create Manager" do
    visit admin_managers_path

    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content user.name
    click_link "Add"
    within("#managers") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete Manager" do
    visit admin_managers_path

    accept_confirm("Delete: Are you sure?") { click_link "Delete" }

    within("#managers") do
      expect(page).not_to have_content manager.name
    end
  end

  context "Search" do
    let(:user)      { create(:user, username: "Taylor Swift", email: "taylor@swift.com") }
    let(:user2)     { create(:user, username: "Stephanie Corneliussen", email: "steph@mrrobot.com") }
    let!(:manager1) { create(:manager, user: user) }
    let!(:manager2) { create(:manager, user: user2) }

    before do
      visit admin_managers_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(manager1.name)
      expect(page).to have_content(manager2.name)

      fill_in "search", with: " "
      click_button "Search"

      expect(page).to have_content("Managers: User search")
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(manager1.name)
      expect(page).not_to have_content(manager2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(manager1.name)
      expect(page).to have_content(manager2.name)

      fill_in "search", with: "Taylor"
      click_button "Search"

      expect(page).to have_content("Managers: User search")
      expect(page).to have_field "search", with: "Taylor"
      expect(page).to have_content(manager1.name)
      expect(page).not_to have_content(manager2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(manager1.email)
      expect(page).to have_content(manager2.email)

      fill_in "search", with: manager2.email
      click_button "Search"

      expect(page).to have_content("Managers: User search")
      expect(page).to have_field "search", with: manager2.email
      expect(page).to have_content(manager2.email)
      expect(page).not_to have_content(manager1.email)
    end

    scenario "Delete after searching" do
      fill_in "Search user by name or email", with: manager2.email
      click_button "Search"

      accept_confirm("Delete: Are you sure?") { click_link "Delete" }

      expect(page).to have_content(manager1.email)
      expect(page).not_to have_content(manager2.email)
    end
  end
end
