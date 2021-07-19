require "rails_helper"

describe "Unsubscribes" do
  let!(:user) { create(:user) }

  scenario "Edit page" do
    visit edit_unsubscribe_path(user.unsubscribe_hash)

    expect(page).to have_content "Notifications"
    expect(page).to have_content "Notify me by email when someone comments on my proposals or debates"
    expect(page).to have_content "Notify me by email when someone replies to my comments"
    expect(page).to have_content "Receive by email website relevant information"
    expect(page).to have_content "Receive a summary of proposal notifications"
    expect(page).to have_content "Receive emails about direct messages"
  end

  context "Update" do
    scenario "Allow update the status notification" do
      user.update!(email_on_comment: true,
                   email_on_comment_reply: true,
                   email_on_direct_message: true,
                   email_digest: true,
                   newsletter: true)
      visit edit_unsubscribe_path(user.unsubscribe_hash)

      uncheck "Notify me by email when someone comments on my proposals or debates"
      uncheck "Notify me by email when someone replies to my comments"
      uncheck "Receive by email website relevant information"
      uncheck "Receive a summary of proposal notifications"
      uncheck "Receive emails about direct messages"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(user.reload.email_on_comment).to eq false
      expect(user.reload.email_on_comment_reply).to eq false
      expect(user.reload.email_on_direct_message).to eq false
      expect(user.reload.email_digest).to eq false
      expect(user.reload.newsletter).to eq false
    end
  end
end
