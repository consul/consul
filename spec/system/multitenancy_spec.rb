require "rails_helper"

describe "Multitenancy", :js do
  before do
    create(:tenant, subdomain: "mars")
    create(:tenant, subdomain: "venus")
  end

  scenario "Disabled features", js: false do
    Apartment::Tenant.switch("mars") { Setting["process.debates"] = true }
    Apartment::Tenant.switch("venus") { Setting["process.debates"] = nil }

    with_subdomain("mars") do
      visit debates_path

      expect(page).to have_selector("#debates")
    end

    with_subdomain("venus") do
      expect { visit debates_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  scenario "Content is different for differents tenants" do
    Apartment::Tenant.switch("mars") do
      create(:poll, name: "Human rights for Martians?")
    end

    with_subdomain("mars") do
      visit polls_path

      expect(page).to have_content "Human rights for Martians?"
    end

    with_subdomain("venus") do
      visit polls_path

      expect(page).to have_content("There are no open votings")
    end
  end

  scenario "PostgreSQL extensions work for tenats" do
    Apartment::Tenant.switch("mars") { login_as(create(:user)) }

    with_subdomain("mars") do
      visit new_proposal_path
      fill_in "Proposal title", with: "Use the unaccent extension in Mars"
      fill_in "Proposal summary", with: "tsvector for Maria and María should be the same"
      fill_in_ckeditor "Proposal text", with: "Maria the Martian wants to be like María the Martian"
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."
      expect(page).to have_content "Use the unaccent extension in Mars"
    end
  end

  scenario "Creating content in one tenant doesn't affect other tenants" do
    Apartment::Tenant.switch("mars") { login_as(create(:user)) }

    with_subdomain("mars") do
      visit new_debate_path
      fill_in "Debate title", with: "Found any water here?"
      fill_in_ckeditor "Initial debate text", with: "Found any water here?"
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Start a debate"

      expect(page).to have_content "Debate created successfully."
      expect(page).to have_content "Found any water here?"
    end

    with_subdomain("venus") do
      visit debates_path

      expect(page).not_to have_selector(".debate")
    end
  end

  scenario "Users from another tenant cannot create content" do
    with_subdomain("mars") do
      login_as(create(:user))
      visit root_path
    end

    with_subdomain("venus") do
      visit new_debate_path

      expect(page).to have_content "You must sign in or register to continue."
    end
  end

  scenario "Users from another tenant cannot vote", :js do
    Apartment::Tenant.switch("mars") { create(:proposal, title: "Earth invasion") }

    with_subdomain("venus") do
      login_as(create(:user))
      visit root_path
    end

    with_subdomain("mars") do
      visit proposals_path

      within(".proposal", text: "Earth invasion") do
        find("div.supports").hover
        expect_message_you_need_to_sign_in
      end
    end
  end

  scenario "Sign up into subdomain" do
    with_subdomain("mars") do
      visit "/"
      click_link "Register"

      fill_in "Username", with: "Marty McMartian"
      fill_in "Email", with: "marty@consul.dev"
      fill_in "Password", with: "20151021"
      fill_in "Confirm password", with: "20151021"
      check "By registering you accept the terms and conditions of use"
      click_button "Register"

      confirm_email

      expect(page).to have_content "Your account has been confirmed."
    end
  end

  scenario "Users from another tenant can't sign in" do
    Apartment::Tenant.switch("mars") { create(:user, email: "marty@consul.dev", password: "20151021") }

    with_subdomain("mars") do
      visit new_user_session_path
      fill_in "Email or username", with: "marty@consul.dev"
      fill_in "Password", with: "20151021"
      click_button "Enter"

      expect(page).to have_content "You have been signed in successfully."
    end

    with_subdomain("venus") do
      visit new_user_session_path
      fill_in "Email or username", with: "marty@consul.dev"
      fill_in "Password", with: "20151021"
      click_button "Enter"

      expect(page).to have_content "Invalid Email or username or password."
    end
  end
end
