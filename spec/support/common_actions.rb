Dir["./spec/support/common_actions/*.rb"].each { |f| require f }

module CommonActions
  include Budgets
  include Comments
  include Debates
  include Emails
  include Notifications
  include Polls
  include Proposals
  include RemoteCensusMock
  include Tags
  include Translations
  include Users
  include Verifications
  include Votes

  def select_language(language_name)
    within ".locale-switcher" do
      click_link "English"
      click_link language_name
    end
  end

  def app_host
    "#{Capybara.app_host}:#{Capybara::Server.ports.values.last}"
  end

  def fill_in_signup_form(email = "manuela@consul.dev", password = "judgementday")
    fill_in "user_username",              with: "Manuela Carmena #{rand(99999)}"
    fill_in "user_email",                 with: email
    fill_in "user_password",              with: password
    fill_in "user_password_confirmation", with: password
    check "user_terms_of_service"
  end

  def validate_officer
    allow_any_instance_of(Officing::BaseController).
    to receive(:verify_officer_assignment).and_return(true)
  end

  def fill_in_proposal
    fill_in "Proposal title", with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is very important because..."
    fill_in "External video URL", with: "https://www.youtube.com/watch?v=yPQfcG-eimk"
    fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"
    check "I agree to the Privacy Policy and the Terms and conditions of use"
  end

  def set_officing_booth(booth = nil)
    booth = create(:poll_booth) if booth.blank?

    allow_any_instance_of(Officing::BaseController).
    to receive(:current_booth).and_return(booth)
  end

  def click_sdg_goal(code)
    within(".sdg-related-list-selector .goals") do
      find("[data-code='#{code}'] + label").click
    end
  end

  def remove_sdg_goal_or_target_tag(code)
    within "span[data-val='#{code}']" do
      click_button "Remove"
    end
  end
end
