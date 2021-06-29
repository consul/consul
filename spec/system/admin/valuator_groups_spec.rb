require "rails_helper"

describe "Valuator groups", :admin do
  scenario "Index" do
    group1 = create(:valuator_group)
    group2 = create(:valuator_group)
    3.times { create(:valuator, valuator_group: group1) }

    visit admin_valuator_groups_path

    within("#valuator_group_#{group1.id}") do
      expect(page).to have_content group1.name
      expect(page).to have_content 3
    end

    within("#valuator_group_#{group2.id}") do
      expect(page).to have_content group2.name
      expect(page).to have_content 0
    end
  end

  scenario "Show" do
    group = create(:valuator_group)
    valuator1 = create(:valuator, valuator_group: group)
    valuator2 = create(:valuator, valuator_group: group)
    valuator3 = create(:valuator, valuator_group: nil)

    visit admin_valuator_group_path(group)

    expect(page).to have_content group.name

    within("#valuators") do
      expect(page).to have_link(valuator1.email, href: admin_valuator_path(valuator1))
      expect(page).to have_link(valuator2.email, href: admin_valuator_path(valuator2))
      expect(page).not_to have_link(valuator3.email)
    end
  end

  scenario "Create" do
    visit admin_valuators_path

    click_link "Valuator Groups"
    click_link "Create valuators group"

    fill_in "valuator_group_name", with: "Health"
    click_button "Create valuators group"

    expect(page).to have_content "Valuator group created successfully"
    expect(page).to have_content "There is 1 valuator group"
    expect(page).to have_content "Health"
  end

  scenario "Update" do
    create(:valuator_group, name: "Health")

    visit admin_valuator_groups_path
    click_link "Edit"

    fill_in "valuator_group_name", with: "Health and Sports"
    click_button "Save valuators group"

    expect(page).to have_content "Valuator group updated successfully"
    expect(page).to have_content "Health and Sports"
  end

  scenario "Delete" do
    create(:valuator_group)

    visit admin_valuator_groups_path
    accept_confirm("Delete: Are you sure?") { click_link "Delete" }

    expect(page).to have_content "Valuator group deleted successfully"
    expect(page).to have_content "There are no valuator groups"
  end

  context "Assign valuators to groups" do
    let(:valuator) { create(:valuator) }

    scenario "Add a valuator to a group" do
      create(:valuator_group, name: "Health")

      visit edit_admin_valuator_path(valuator)

      select "Health", from: "valuator_valuator_group_id"
      click_button "Update Valuator"

      expect(page).to have_content "Valuator updated successfully"
      expect(page).to have_content "Health"
    end

    scenario "Update a valuator's group" do
      valuator.update!(valuator_group: create(:valuator_group, name: "Economy"))
      create(:valuator_group, name: "Health")

      visit edit_admin_valuator_path(valuator)
      select "Economy", from: "valuator_valuator_group_id"
      click_button "Update Valuator"

      expect(page).to have_content "Valuator updated successfully"
      expect(page).to have_content "Economy"
    end

    scenario "Remove a valuator from a group" do
      valuator.update!(valuator_group: create(:valuator_group, name: "Health"))

      visit edit_admin_valuator_path(valuator)
      select "", from: "valuator_valuator_group_id"
      click_button "Update Valuator"

      expect(page).to have_content "Valuator updated successfully"
      expect(page).not_to have_content "Health"
    end
  end
end
