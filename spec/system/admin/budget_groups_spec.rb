require "rails_helper"

describe "Admin budget groups", :admin do
  let(:budget) { create(:budget, :drafting) }

  context "Load" do
    let!(:budget) { create(:budget, slug: "budget_slug") }
    let!(:group)  { create(:budget_group, slug: "group_slug", budget: budget) }

    scenario "finds budget and group by slug" do
      visit edit_admin_budget_group_path("budget_slug", "group_slug")
      expect(page).to have_content(budget.name)
      expect(page).to have_field "Group name", with: group.name
    end
  end

  context "Index" do
    scenario "Displaying no groups for budget" do
      visit admin_budget_groups_path(budget)

      expect(page).to have_content "There are no groups."
    end

    scenario "Displaying groups" do
      group1 = create(:budget_group, budget: budget)

      group2 = create(:budget_group, budget: budget)
      create(:budget_heading, group: group2)

      group3 = create(:budget_group, budget: budget, max_votable_headings: 2)
      3.times { create(:budget_heading, group: group3) }

      visit admin_budget_groups_path(budget)
      expect(page).to have_content "There are 3 groups"

      within "#budget_group_#{group1.id}" do
        expect(page).to have_content(group1.name)
        expect(page).to have_content(group1.max_votable_headings)
        expect(page).to have_content(group1.headings.count)
        expect(page).to have_link "Manage headings"
      end

      within "#budget_group_#{group2.id}" do
        expect(page).to have_content(group2.name)
        expect(page).to have_content(group2.max_votable_headings)
        expect(page).to have_content(group2.headings.count)
        expect(page).to have_link "Manage headings"
      end

      within "#budget_group_#{group3.id}" do
        expect(page).to have_content(group3.name)
        expect(page).to have_content(group3.max_votable_headings)
        expect(page).to have_content(group3.headings.count)
        expect(page).to have_link "Manage headings"
      end
    end

    scenario "Delete a group without headings" do
      group = create(:budget_group, budget: budget)

      visit admin_budget_groups_path(budget)
      within("#budget_group_#{group.id}") do
        accept_confirm("Delete: Are you sure?") { click_link "Delete" }
      end

      expect(page).to have_content "Group deleted successfully"
      expect(page).not_to have_selector "#budget_group_#{group.id}"
    end

    scenario "Try to delete a group with headings" do
      group = create(:budget_group, budget: budget)
      create(:budget_heading, group: group)

      visit admin_budget_groups_path(budget)
      within("#budget_group_#{group.id}") do
        accept_confirm("Delete: Are you sure?") { click_link "Delete" }
      end

      expect(page).to have_content "You cannot delete a Group that has associated headings"
      expect(page).to have_selector "#budget_group_#{group.id}"
    end
  end

  context "New" do
    scenario "Create group" do
      visit admin_budget_groups_path(budget)
      click_link "Create new group"

      fill_in "Group name", with: "All City"

      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"
      expect(page).to have_content "All City"
    end

    scenario "Maximum number of headings in which a user can vote is set to 1 by default" do
      visit new_admin_budget_group_path(budget)
      fill_in "Group name", with: "All City"

      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"

      within all("thead th")[1] do
        expect(page).to have_content("Maximum number of headings in which a user can select projects")
      end

      within "tbody tr" do
        within all("td")[1] { expect(page.text).to eq "1" }
      end
    end

    scenario "Group name is mandatory" do
      visit new_admin_budget_group_path(budget)
      click_button "Create new group"

      expect(page).not_to have_content "Group created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Group name")
      expect(page).to have_content "can't be blank"
    end
  end

  context "Edit" do
    scenario "Show group information" do
      group = create(:budget_group, budget: budget, max_votable_headings: 2)
      2.times { create(:budget_heading, group: group) }

      visit admin_budget_groups_path(budget)
      within("#budget_group_#{group.id}") { click_link "Edit" }

      expect(page).to have_field "Group name", with: group.name
      expect(page).to have_field "Maximum number of headings in which a user can select projects", with: "2"
    end

    describe "Select for maxium number of headings to select projects" do
      scenario "is present if there are headings in the group" do
        group = create(:budget_group, budget: budget)
        create(:budget_heading, group: group)

        visit edit_admin_budget_group_path(budget, group)

        expect(page).to have_field "Maximum number of headings in which a user can select projects"
      end

      scenario "is not present if there are no headings in the group" do
        group = create(:budget_group, budget: budget)

        visit edit_admin_budget_group_path(budget, group)

        expect(page).not_to have_field "Maximum number of headings in which a user can select projects"
      end
    end

    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      group = create(:budget_group, budget: budget, name: "Old English Name")

      visit edit_admin_budget_group_path(budget, group)

      select "Español", from: :add_language
      fill_in "Group name", with: "Spanish name"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit budget_group_path(budget, id: "old-english-name")

      expect(page).to have_content "Select a heading"

      visit edit_admin_budget_group_path(budget, group)

      select "English", from: :select_language
      fill_in "Group name", with: "New English Name"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit budget_group_path(budget, id: "new-english-name")

      expect(page).to have_content "Select a heading"
    end
  end

  context "Update" do
    let!(:group) { create(:budget_group, budget: budget, name: "All City") }

    scenario "Updates group" do
      2.times { create(:budget_heading, group: group) }

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "All City"

      fill_in "Group name", with: "Districts"
      select "2", from: "Maximum number of headings in which a user can select projects"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "Districts"
      expect(page).to have_field "Maximum number of headings in which a user can select projects", with: "2"
    end

    scenario "Group name is already used" do
      create(:budget_group, budget: budget, name: "Districts")

      visit edit_admin_budget_group_path(budget, group)
      expect(page).to have_field "Group name", with: "All City"

      fill_in "Group name", with: "Districts"
      click_button "Save group"

      expect(page).not_to have_content "Group updated successfully"
      expect(page).to have_css(".is-invalid-label", text: "Group name")
      expect(page).to have_css("small.form-error", text: "has already been taken")
    end
  end
end
