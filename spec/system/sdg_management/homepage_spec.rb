require "rails_helper"

describe "SDG homepage configuration" do
  before do
    Setting["feature.sdg"] = true
    login_as(create(:sdg_manager).user)
  end

  describe "Show" do
    scenario "Visit the index" do
      visit sdg_management_root_path

      within("#side_menu") do
        click_link "SDG homepage"
      end

      expect(page).to have_title "SDG content - Homepage configuration"
    end

    scenario "Create card" do
      visit sdg_management_homepage_path
      click_link "Create planning card"

      within(".translatable-fields") { fill_in "Title", with: "My planning card" }
      click_button "Create card"

      within(".planning-cards") do
        expect(page).to have_content "My planning card"
      end

      within(".sensitization-cards") do
        expect(page).to have_content "There are no cards for this phase"
      end
    end

    scenario "Update card" do
      create(:widget_card, cardable: SDG::Phase["monitoring"], title: "My monitoring card")

      visit sdg_management_homepage_path
      within(".monitoring-cards") { click_link "Edit" }

      within(".translatable-fields") { fill_in "Title", with: "Updated monitoring card" }
      click_button "Save card"

      within(".monitoring-cards") do
        expect(page).to have_css "tbody tr", count: 1
        expect(page).to have_content "Updated monitoring card"
        expect(page).not_to have_content "My monitoring card"
      end
    end

    scenario "Create header card" do
      visit sdg_management_homepage_path
      click_link "Create header"

      within(".translatable-fields") { fill_in "Title", with: "My header" }
      click_button "Create card"

      within(".sdg-header") do
        expect(page).to have_content "My header"
        expect(page).not_to have_content "Create header"
      end
    end

    scenario "Update header card" do
      create(:widget_card, cardable: WebSection.find_by!(name: "sdg"))
      visit sdg_management_homepage_path
      within ".sdg-header" do
        click_link "Edit"
      end

      within(".translatable-fields") { fill_in "Title", with: "My header update" }
      click_button "Save card"

      expect(page).to have_content "My header update"
    end

    scenario "Remove header card" do
      create(:widget_card, title: "SDG Header", cardable: WebSection.find_by!(name: "sdg"))
      visit sdg_management_homepage_path

      within ".sdg-header" do
        accept_confirm("Delete: Are you sure?") { click_link "Delete" }
      end

      expect(page).not_to have_content "SDG Header"
    end
  end
end
