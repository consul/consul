require "rails_helper"

describe "Admin newsletter emails", :admin do
  before do
    create(:budget)
  end

  context "Show" do
    scenario "Valid newsletter" do
      newsletter = create(:newsletter, subject: "This is a subject",
                                       segment_recipient: "all_users",
                                       from: "no-reply@consul.dev",
                                       body: "This is a body")

      visit admin_newsletter_path(newsletter)

      expect(page).to have_link "Go back", href: admin_newsletters_path
      expect(page).to have_content "This is a subject"
      expect(page).to have_content I18n.t("admin.segment_recipient.#{newsletter.segment_recipient}")
      expect(page).to have_content "no-reply@consul.dev"
      expect(page).to have_content "This is a body"
    end

    scenario "Invalid newsletter" do
      invalid_newsletter = create(:newsletter)
      invalid_newsletter.update_column(:segment_recipient, "invalid_segment")

      visit admin_newsletter_path(invalid_newsletter)

      expect(page).to have_content("Recipients user segment is invalid")
    end
  end

  context "Index" do
    scenario "Valid newsletters" do
      newsletters = 3.times.map { create(:newsletter) }

      visit admin_newsletters_path

      expect(page).to have_css(".newsletter", count: 3)

      newsletters.each do |newsletter|
        segment_recipient = I18n.t("admin.segment_recipient.#{newsletter.segment_recipient}")
        within("#newsletter_#{newsletter.id}") do
          expect(page).to have_content newsletter.subject
          expect(page).to have_content segment_recipient
        end
      end
    end

    scenario "Invalid newsletter" do
      invalid_newsletter = create(:newsletter)
      invalid_newsletter.update_column(:segment_recipient, "invalid_segment")

      visit admin_newsletters_path

      expect(page).to have_content("Recipients user segment is invalid")
    end
  end

  scenario "Create" do
    visit admin_newsletters_path
    click_link "New newsletter"

    expect(page).to have_link "Go back", href: admin_newsletters_path

    fill_in_newsletter_form(subject: "This is a subject",
                            segment_recipient: "Proposal authors",
                            body: "This is a body")
    click_button "Create Newsletter"

    expect(page).to have_content "Newsletter created successfully"
    expect(page).to have_content "This is a subject"
    expect(page).to have_content "Proposal authors"
    expect(page).to have_content "no-reply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Update" do
    newsletter = create(:newsletter)

    visit admin_newsletters_path
    within("#newsletter_#{newsletter.id}") do
      click_link "Edit"
    end

    expect(page).to have_link "Go back", href: admin_newsletters_path

    fill_in_newsletter_form(subject: "This is a subject",
                            segment_recipient: "Investment authors in the current budget",
                            body: "This is a body")
    click_button "Update Newsletter"

    expect(page).to have_content "Newsletter updated successfully"
    expect(page).to have_content "This is a subject"
    expect(page).to have_content "Investment authors in the current budget"
    expect(page).to have_content "no-reply@consul.dev"
    expect(page).to have_content "This is a body"
  end

  scenario "Destroy" do
    newsletter = create(:newsletter)

    visit admin_newsletters_path
    within("#newsletter_#{newsletter.id}") do
      accept_confirm("Delete: Are you sure?") { click_link "Delete" }
    end

    expect(page).to have_content "Newsletter deleted successfully"
    expect(page).to have_css(".newsletter", count: 0)
  end

  scenario "Errors on create" do
    visit new_admin_newsletter_path

    click_button "Create Newsletter"

    expect(page).to have_content error_message
  end

  scenario "Errors on update" do
    newsletter = create(:newsletter)
    visit edit_admin_newsletter_path(newsletter)

    fill_in "newsletter_subject", with: ""
    click_button "Update Newsletter"

    expect(page).to have_content error_message
  end

  context "Send newsletter" do
    scenario "Sends newsletter emails" do
      newsletter = create(:newsletter)
      visit admin_newsletter_path(newsletter)

      accept_confirm { click_link "Send" }

      expect(page).to have_content "Newsletter sent successfully"
    end

    scenario "Invalid newsletter cannot be sent" do
      invalid_newsletter = create(:newsletter)
      invalid_newsletter.update_column(:segment_recipient, "invalid_segment")
      visit admin_newsletter_path(invalid_newsletter)

      expect(page).not_to have_link("Send")
    end
  end

  context "Counter of emails sent" do
    scenario "Display counter" do
      newsletter = create(:newsletter, segment_recipient: "administrators")
      visit admin_newsletter_path(newsletter)

      accept_confirm { click_link "Send" }

      expect(page).to have_content "Newsletter sent successfully"

      expect(page).to have_content "1 affected users"
      expect(page).to have_content "1 email sent"
    end
  end

  scenario "Select list of users to send newsletter" do
    UserSegments::SEGMENTS.each do |user_segment|
      visit new_admin_newsletter_path

      fill_in_newsletter_form(segment_recipient: I18n.t("admin.segment_recipient.#{user_segment}"))
      click_button "Create Newsletter"

      expect(page).to have_content(I18n.t("admin.segment_recipient.#{user_segment}"))
    end
  end
end
