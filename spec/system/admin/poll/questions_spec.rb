require "rails_helper"

describe "Admin poll questions", :admin do
  scenario "Index" do
    poll1 = create(:poll)
    poll2 = create(:poll)
    poll3 = create(:poll)
    proposal = create(:proposal)
    question1 = create(:poll_question, poll: poll1)
    question2 = create(:poll_question, poll: poll2)
    question3 = create(:poll_question, poll: poll3, proposal: proposal)

    visit admin_poll_path(poll1)
    expect(page).to have_content(poll1.name)

    within("#poll_question_#{question1.id}") do
      expect(page).to have_content(question1.title)
      expect(page).to have_link "Edit answers"
      expect(page).to have_link "Edit"
      expect(page).to have_link "Delete"
    end

    visit admin_poll_path(poll2)
    expect(page).to have_content(poll2.name)

    within("#poll_question_#{question2.id}") do
      expect(page).to have_content question2.title
      expect(page).to have_link "Edit answers"
      expect(page).to have_link "Edit"
      expect(page).to have_link "Delete"
    end

    visit admin_poll_path(poll3)
    expect(page).to have_content(poll3.name)

    within("#poll_question_#{question3.id}") do
      expect(page).to have_content question3.title
      expect(page).to have_link "(See proposal)", href: proposal_path(question3.proposal)
      expect(page).to have_link "Edit answers"
      expect(page).to have_link "Edit"
      expect(page).to have_link "Delete"
    end
  end

  scenario "Show" do
    geozone = create(:geozone)
    poll = create(:poll, geozone_restricted: true, geozone_ids: [geozone.id])
    question = create(:poll_question, poll: poll)

    visit admin_poll_path(poll)
    click_link "Edit answers"

    expect(page).to have_content(question.title)
    expect(page).to have_content(question.author.name)
  end

  scenario "Create" do
    poll = create(:poll, name: "Movies")
    title = "Star Wars: Episode IV - A New Hope"

    visit admin_poll_path(poll)
    click_link "Create question"

    expect(page).to have_content("Create question to poll Movies")
    expect(page).to have_selector("input[id='poll_question_poll_id'][value='#{poll.id}']",
                                   visible: :hidden)
    fill_in "Question", with: title

    click_button "Save"

    expect(page).to have_content(title)
  end

  scenario "Create from proposal" do
    create(:poll, name: "Proposals")
    proposal = create(:proposal)

    visit admin_proposal_path(proposal)

    expect(page).not_to have_content("This proposal has reached the required supports")
    click_link "Add this proposal to a poll to be voted"

    expect(page).to have_current_path(new_admin_question_path, ignore_query: true)
    expect(page).to have_field("Question", with: proposal.title)

    select "Proposals", from: "poll_question_poll_id"

    click_button "Save"

    expect(page).to have_content(proposal.title)
  end

  scenario "Create from successful proposal" do
    create(:poll, name: "Proposals")
    proposal = create(:proposal, :successful)

    visit admin_proposal_path(proposal)

    expect(page).to have_content("This proposal has reached the required supports")
    click_link "Add this proposal to a poll to be voted"

    expect(page).to have_current_path(new_admin_question_path, ignore_query: true)
    expect(page).to have_field("Question", with: proposal.title)

    select "Proposals", from: "poll_question_poll_id"

    click_button "Save"

    expect(page).to have_content(proposal.title)

    visit admin_questions_path

    expect(page).to have_content(proposal.title)
  end

  scenario "Update" do
    poll = create(:poll)
    question1 = create(:poll_question, poll: poll)

    visit admin_poll_path(poll)

    within("#poll_question_#{question1.id}") do
      click_link "Edit"
    end

    old_title = question1.title
    new_title = "Potatoes are great and everyone should have one"
    fill_in "Question", with: new_title

    click_button "Save"

    expect(page).to have_content "Changes saved"
    expect(page).to have_content new_title
    expect(page).not_to have_content(old_title)
  end

  scenario "Destroy" do
    poll = create(:poll)
    question1 = create(:poll_question, poll: poll)
    question2 = create(:poll_question, poll: poll)

    visit admin_poll_path(poll)

    within("#poll_question_#{question1.id}") do
      accept_confirm { click_link "Delete" }
    end

    expect(page).not_to have_content(question1.title)
    expect(page).to have_content(question2.title)
  end

  pending "Mark all city by default when creating a poll question from a successful proposal"

  context "Poll select box" do
    scenario "translates the poll name in options" do
      poll = create(:poll, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select_language "Español"

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Seleccionar votación", poll.name_es])
    end

    scenario "uses fallback if name is not translated to current locale" do
      unless globalize_french_fallbacks.first == :es
        skip("Spec only useful when French falls back to Spanish")
      end

      poll = create(:poll, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select_language "Français"

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Sélectionner un vote", poll.name_es])
    end
  end

  def globalize_french_fallbacks
    Globalize.fallbacks(:fr).reject { |locale| locale.match(/fr/) }
  end
end
