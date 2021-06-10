require "rails_helper"

describe "Admin SDG managers" do
  let!(:user) { create(:user) }
  let!(:sdg_manager) { create(:sdg_manager) }

  before { login_as(create(:administrator).user) }

  scenario "Index" do
    visit admin_sdg_managers_path

    expect(page).to have_content sdg_manager.name
    expect(page).to have_content sdg_manager.email
    expect(page).not_to have_content user.name
  end

  scenario "Create SDG Manager" do
    visit admin_sdg_managers_path

    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content user.name

    click_link "Add"

    within("#sdg_managers") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete SDG Manager" do
    visit admin_sdg_managers_path

    accept_confirm("Delete: Are you sure?") { click_link "Delete" }

    within("#sdg_managers") do
      expect(page).not_to have_content sdg_manager.name
    end
  end

  context "Search" do
    let(:user)      { create(:user, username: "Taylor Swift", email: "taylor@swift.com") }
    let(:user2)     { create(:user, username: "Stephanie Corneliussen", email: "steph@mrrobot.com") }
    let!(:sdg_manager1) { create(:sdg_manager, user: user) }
    let!(:sdg_manager2) { create(:sdg_manager, user: user2) }

    before do
      visit admin_sdg_managers_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(sdg_manager1.name)
      expect(page).to have_content(sdg_manager2.name)

      fill_in "search", with: " "
      click_button "Search"

      expect(page).to have_content("SDG managers")
      expect(page).to have_content("There are no users.")
      expect(page).not_to have_content(sdg_manager1.name)
      expect(page).not_to have_content(sdg_manager2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(sdg_manager1.name)
      expect(page).to have_content(sdg_manager2.name)

      fill_in "search", with: "Taylor"
      click_button "Search"

      expect(page).to have_content("SDG managers")
      expect(page).to have_content(sdg_manager1.name)
      expect(page).not_to have_content(sdg_manager2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(sdg_manager1.email)
      expect(page).to have_content(sdg_manager2.email)

      fill_in "search", with: sdg_manager2.email
      click_button "Search"

      expect(page).to have_content("SDG managers")
      expect(page).to have_content(sdg_manager2.email)
      expect(page).not_to have_content(sdg_manager1.email)
    end

    scenario "Delete after searching" do
      fill_in "Search user by name or email", with: sdg_manager2.email
      click_button "Search"

      accept_confirm("Delete: Are you sure?") { click_link "Delete" }

      expect(page).to have_content(sdg_manager1.email)
      expect(page).not_to have_content(sdg_manager2.email)
    end
  end
end
