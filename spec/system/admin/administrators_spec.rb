require "rails_helper"

describe "Admin administrators" do
  let!(:admin) { create(:administrator) }
  let!(:user) { create(:user, username: "Jose Luis Balbin") }
  let!(:user_administrator) { create(:administrator, description: "admin_alias") }

  before { login_as(admin.user) }

  scenario "Index" do
    visit admin_administrators_path

    expect(page).to have_content user_administrator.id
    expect(page).to have_content user_administrator.name
    expect(page).to have_content user_administrator.email
    expect(page).to have_content user_administrator.description
    expect(page).not_to have_content user.name
  end

  scenario "Create Administrator" do
    visit admin_administrators_path

    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content user.name
    click_link "Add"
    within("#administrators") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete Administrator" do
    visit admin_administrators_path

    within "#administrator_#{user_administrator.id}" do
      accept_confirm("Delete: Are you sure?") { click_link "Delete" }
    end

    within("#administrators") do
      expect(page).not_to have_content user_administrator.name
    end
  end

  scenario "Delete Administrator when its the current user" do
    visit admin_administrators_path

    within "#administrator_#{admin.id}" do
      accept_confirm("Delete: Are you sure?") { click_link "Delete" }
    end

    within("#error") do
      expect(page).to have_content I18n.t("admin.administrators.administrator.restricted_removal")
    end
  end

  context "Search" do
    let!(:administrator1) do
      create(:administrator, user: create(:user, username: "Bernard Sumner", email: "bernard@sumner.com"))
    end

    let!(:administrator2) do
      create(:administrator, user: create(:user, username: "Tony Soprano", email: "tony@soprano.com"))
    end

    before do
      visit admin_administrators_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(administrator1.name)
      expect(page).to have_content(administrator2.name)

      fill_in "search", with: " "
      click_button "Search"

      expect(page).to have_content("Administrators: User search")
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(administrator1.name)
      expect(page).not_to have_content(administrator2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(administrator1.name)
      expect(page).to have_content(administrator2.name)

      fill_in "search", with: "Sumn"
      click_button "Search"

      expect(page).to have_content("Administrators: User search")
      expect(page).to have_field "search", with: "Sumn"
      expect(page).to have_content(administrator1.name)
      expect(page).not_to have_content(administrator2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(administrator1.email)
      expect(page).to have_content(administrator2.email)

      fill_in "search", with: administrator2.email
      click_button "Search"

      expect(page).to have_content("Administrators: User search")
      expect(page).to have_field "search", with: administrator2.email
      expect(page).to have_content(administrator2.email)
      expect(page).not_to have_content(administrator1.email)
    end

    scenario "Delete after searching" do
      fill_in "Search user by name or email", with: administrator2.email
      click_button "Search"

      accept_confirm("Delete: Are you sure?") { click_link "Delete" }

      expect(page).to have_content(administrator1.email)
      expect(page).not_to have_content(administrator2.email)
    end
  end

  context "Edit" do
    let!(:administrator1) do
      create(:administrator, user: create(:user, username: "Bernard Sumner", email: "bernard@sumner.com"))
    end

    scenario "admin can edit administrator1" do
      visit(edit_admin_administrator_path(administrator1))
      fill_in "administrator_description", with: "Admin Alias"
      click_button "Update Administrator"

      expect(page).to have_content("Administrator updated successfully")
      expect(page).to have_content("Admin Alias")
    end
  end
end
