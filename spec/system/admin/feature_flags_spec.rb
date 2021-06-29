require "rails_helper"

describe "Admin feature flags", :admin do
  before do
    Setting["process.budgets"] = true
  end

  scenario "Enabled features are listed on menu" do
    visit admin_root_path

    within("#side_menu") do
      expect(page).to have_link "Participatory budgets"
      expect(page).to have_link "Debates"
    end
  end

  scenario "Disable a participatory process", :show_exceptions do
    setting = Setting.find_by(key: "process.budgets")
    budget = create(:budget)

    visit admin_settings_path
    within("#settings-tabs") { click_link "Participation processes" }

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Disable"
      expect(page).not_to have_button "Enable"

      accept_confirm("Disable: Are you sure?") { click_button "Disable" }
    end

    expect(page).to have_content "Value updated"

    within("#side_menu") do
      expect(page).not_to have_link "Participatory budgets"
    end

    visit budget_path(budget)

    expect(page).to have_title "Forbidden"

    visit admin_budgets_path

    expect(page).to have_current_path admin_budgets_path
    expect(page).to have_title "Forbidden"
  end

  scenario "Enable a disabled participatory process" do
    Setting["process.budgets"] = nil
    setting = Setting.find_by(key: "process.budgets")

    visit admin_root_path

    within("#side_menu") do
      expect(page).not_to have_link "Participatory budgets"
    end

    visit admin_settings_path
    within("#settings-tabs") { click_link "Participation processes" }

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Enable"
      expect(page).not_to have_button "Disable"

      accept_confirm("Enable: Are you sure?") { click_button "Enable" }
    end

    expect(page).to have_content "Value updated"

    within("#side_menu") do
      expect(page).to have_link "Participatory budgets"
    end
  end

  scenario "Disable a feature" do
    setting = Setting.find_by(key: "feature.twitter_login")

    visit admin_settings_path
    click_link "Features"

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Disable"
      expect(page).not_to have_button "Enable"

      accept_confirm("Disable: Are you sure?") { click_button "Disable" }
    end

    expect(page).to have_content "Value updated"

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Enable"
      expect(page).not_to have_button "Disable"
    end
  end

  scenario "Enable a disabled feature" do
    setting = Setting.find_by(key: "feature.map")

    visit admin_settings_path
    click_link "Features"

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Enable"
      expect(page).not_to have_button "Disable"

      accept_confirm("Enable: Are you sure?") { click_button "Enable" }
    end

    expect(page).to have_content "Value updated"

    within("#edit_setting_#{setting.id}") do
      expect(page).to have_button "Disable"
      expect(page).not_to have_button "Enable"
    end
  end
end
