require "rails_helper"

describe "Admin valuators", :admin do
  let!(:user) { create(:user, username: "Jose Luis Balbin") }
  let!(:valuator) { create(:valuator, description: "Very reliable") }

  scenario "Show" do
    visit admin_valuator_path(valuator)

    expect(page).to have_content valuator.name
    expect(page).to have_content "Very reliable"
    expect(page).to have_content valuator.email
    expect(page).to have_content "Can comment, Can edit dossier"
  end

  scenario "Index" do
    visit admin_valuators_path

    expect(page).to have_content(valuator.name)
    expect(page).to have_content(valuator.email)
    expect(page).not_to have_content(user.name)
  end

  scenario "Create" do
    visit admin_valuators_path

    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content(user.name)
    click_button "Add to valuators"

    within("#valuators") do
      expect(page).to have_content(user.name)
    end
  end

  scenario "Edit" do
    visit edit_admin_valuator_path(valuator)

    expect(page).to have_field("Can create comments", checked: true)
    expect(page).to have_field("Can edit dossiers", checked: true)

    fill_in "valuator_description", with: "Valuator for health"
    uncheck "Can edit dossiers"
    click_button "Update Valuator"

    expect(page).to have_content "Valuator updated successfully"
    expect(page).to have_content valuator.email
    expect(page).to have_content "Valuator for health"
    expect(page).to have_content "Can comment"
    expect(page).not_to have_content "Can edit dossier"
  end

  scenario "Destroy" do
    visit admin_valuators_path

    accept_confirm("Delete: Are you sure?") { click_link "Delete" }

    within("#valuators") do
      expect(page).not_to have_content(valuator.name)
    end
  end

  context "Search" do
    let!(:user1) { create(:user, username: "David Foster Wallace", email: "david@wallace.com") }
    let!(:user2) { create(:user, username: "Steven Erikson", email: "steven@erikson.com") }
    let!(:valuator1) { create(:valuator, user: user1) }
    let!(:valuator2) { create(:valuator, user: user2) }

    before do
      visit admin_valuators_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(valuator1.name)
      expect(page).to have_content(valuator2.name)

      fill_in "search", with: " "
      click_button "Search"

      expect(page).to have_content("Valuators: User search")
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(valuator1.name)
      expect(page).not_to have_content(valuator2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(valuator1.name)
      expect(page).to have_content(valuator2.name)

      fill_in "search", with: "Foster"
      click_button "Search"

      expect(page).to have_content("Valuators: User search")
      expect(page).to have_field "search", with: "Foster"
      expect(page).to have_content(valuator1.name)
      expect(page).not_to have_content(valuator2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(valuator1.email)
      expect(page).to have_content(valuator2.email)

      fill_in "search", with: valuator2.email
      click_button "Search"

      expect(page).to have_content("Valuators: User search")
      expect(page).to have_field "search", with: valuator2.email
      expect(page).to have_content(valuator2.email)
      expect(page).not_to have_content(valuator1.email)
    end
  end
end
