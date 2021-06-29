require "rails_helper"

describe "Admin tags", :admin do
  before do
    create(:tag, :category, name: "Existence")
  end

  scenario "Index" do
    debate = create(:debate)
    debate.tag_list.add(create(:tag, :category, name: "supertag"))
    visit admin_tags_path

    expect(page).to have_content "Existence"
    expect(page).to have_content "supertag"
  end

  scenario "Create" do
    visit admin_tags_path

    expect(page).not_to have_content "important issues"

    within("form.new_tag") do
      fill_in "tag_name", with: "important issues"
      click_button "Create topic"
    end

    visit admin_tags_path

    expect(page).to have_content "important issues"
  end

  scenario "Delete" do
    tag2 = create(:tag, :category, name: "bad tag")
    create(:debate, tag_list: "bad tag")

    visit admin_tags_path

    expect(page).to have_content "Existence"
    expect(page).to have_content "bad tag"

    within("#tag_#{tag2.id}") do
      accept_confirm("Delete topic: Are you sure?") { click_link "Delete topic" }
    end

    expect(page).not_to have_content "bad tag"
    expect(page).to have_content "Existence"
  end

  scenario "Delete tag with hidden taggables" do
    tag2 = create(:tag, :category, name: "bad tag")
    debate = create(:debate, tag_list: "bad tag")
    debate.hide

    visit admin_tags_path

    expect(page).to have_content "Existence"
    expect(page).to have_content "bad tag"

    within("#tag_#{tag2.id}") do
      accept_confirm("Delete topic: Are you sure?") { click_link "Delete topic" }
    end

    expect(page).not_to have_content "bad tag"
    expect(page).to have_content "Existence"
  end

  context "Manage only tags of kind category" do
    scenario "Index shows only categories" do
      create(:tag, name: "Not a category")

      visit admin_tags_path

      expect(page).to have_content "Existence"
      expect(page).not_to have_content "Not a category"
    end

    scenario "Create instanciates tags of correct kind" do
      visit admin_tags_path

      within("form.new_tag") do
        fill_in "tag_name", with: "wow_category"
        click_button "Create topic"
      end

      within "tbody" do
        expect(page).to have_content "Existence"
        expect(page).to have_content "wow_category"
      end
    end
  end

  scenario "Upgrade tag to category" do
    create(:tag, name: "Soon a category")

    visit admin_tags_path

    within("form.new_tag") do
      fill_in "tag_name", with: "Soon a category"
      click_button "Create topic"
    end

    expect(page).to have_content "Soon a category"
  end
end
