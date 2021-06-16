module Notifications
  def click_notifications_icon
    find("#notifications a").click
  end

  def model_name(described_class)
    return :proposal_notification if described_class == ProposalNotification

    described_class.name.gsub("::", "_").downcase.to_sym
  end

  def comment_body(resource)
    if resource.class.name == "Legislation::Question"
      "Leave your answer"
    else
      "Leave your comment"
    end
  end

  def submit_comment_text(resource)
    if resource.class.name == "Legislation::Question"
      "Publish answer"
    else
      "Publish comment"
    end
  end

  def create_proposal_notification(proposal)
    login_as(proposal.author)
    visit root_path

    click_link "My content"

    within("#proposal_#{proposal.id}") do
      click_link "Dashboard"
    end

    within("#side_menu") do
      click_link "Message to users"
    end

    click_link "Send notification to proposal followers"

    fill_in "proposal_notification_title", with: "Thanks for supporting proposal: #{proposal.title}"
    fill_in "proposal_notification_body", with: "Please share it with others! #{proposal.summary}"
    click_button "Send notification"

    expect(page).to have_content "Your message has been sent correctly."
    Notification.last
  end

  def path_for(resource)
    polymorphic_path(resource)
  end

  def error_message(resource_model = nil)
    resource_model ||= "(.*)"
    field_check_message = "Please check the marked fields to know how to correct them:"
    /\d errors? prevented this #{resource_model} from being saved.(\n| )#{field_check_message}/
  end

  def fill_in_admin_notification_form(options = {})
    select (options[:segment_recipient] || "All users"), from: :admin_notification_segment_recipient
    fill_in "Title", with: (options[:title] || "This is the notification title")
    fill_in "Text", with: (options[:body] || "This is the notification body")
    fill_in :admin_notification_link, with: (options[:link] || "https://www.decide.madrid.es/vota")
  end
end
