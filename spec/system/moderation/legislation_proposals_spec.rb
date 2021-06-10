require "rails_helper"

describe "Moderate legislation proposals" do
  scenario "Hide" do
    citizen               = create(:user)
    legislation_process   = create(:legislation_process)
    legislation_proposal  = create(:legislation_proposal, legislation_process_id: legislation_process.id)
    moderator             = create(:moderator)

    login_as(moderator.user)
    visit legislation_process_proposal_path(legislation_process, legislation_proposal)

    within("#legislation_proposal_#{legislation_proposal.id}") do
      accept_confirm("Hide: Are you sure?") { click_link "Hide" }
    end

    expect(page).to have_css("#legislation_proposal_#{legislation_proposal.id}.faded")

    logout
    login_as(citizen)
    visit legislation_process_proposals_path(legislation_process)

    expect(page).to have_css(".proposal-content", count: 0)
    expect(page).not_to have_link("Hide")
  end
end
