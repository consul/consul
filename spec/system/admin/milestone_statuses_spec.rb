require "rails_helper"

describe "Admin milestone statuses", :admin do
  context "Index" do
    scenario "Displaying only not hidden statuses" do
      status1 = create(:milestone_status)
      status2 = create(:milestone_status)

      status1.destroy!

      visit admin_milestone_statuses_path

      expect(page).not_to have_content status1.name
      expect(page).not_to have_content status1.description

      expect(page).to have_content status2.name
      expect(page).to have_content status2.description
    end

    scenario "Displaying no statuses text" do
      visit admin_milestone_statuses_path

      expect(page).to have_content("There are no milestone statuses created")
    end
  end

  context "New" do
    scenario "Create status" do
      visit admin_milestone_statuses_path

      click_link "Create new milestone status"

      fill_in "milestone_status_name", with: "New status name"
      fill_in "milestone_status_description", with: "This status description"
      click_button "Create Milestone Status"

      expect(page).to have_content "New status name"
      expect(page).to have_content "This status description"
    end

    scenario "Show validation errors in status form" do
      visit admin_milestone_statuses_path

      click_link "Create new milestone status"

      fill_in "milestone_status_description", with: "This status description"
      click_button "Create Milestone Status"

      within "#new_milestone_status" do
        expect(page).to have_content "can't be blank", count: 1
      end
    end
  end

  context "Edit" do
    scenario "Change name and description" do
      status = create(:milestone_status)

      visit admin_milestone_statuses_path

      within("#milestone_status_#{status.id}") do
        click_link "Edit"
      end

      fill_in "milestone_status_name", with: "Other status name"
      fill_in "milestone_status_description", with: "Other status description"
      click_button "Update Milestone Status"

      expect(page).to have_content "Other status name"
      expect(page).to have_content "Other status description"
    end
  end

  context "Delete" do
    scenario "Hides status" do
      status = create(:milestone_status)

      visit admin_milestone_statuses_path

      within("#milestone_status_#{status.id}") do
        accept_confirm("Delete: Are you sure?") { click_link "Delete" }
      end

      expect(page).not_to have_content status.name
      expect(page).not_to have_content status.description
    end
  end
end
