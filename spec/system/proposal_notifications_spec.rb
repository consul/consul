require "rails_helper"

describe "Proposal Notifications" do
  scenario "Send a notification" do
    author = create(:user, :with_proposal)

    login_as(author)
    visit root_path

    click_link "My content"
    click_link "Dashboard"

    within("#side_menu") do
      click_link "Message to users"
    end

    click_link "Send notification to proposal followers"

    fill_in "proposal_notification_title", with: "Thank you for supporting my proposal"
    fill_in "proposal_notification_body", with: "Please share it with "\
                                                "others so we can make it happen!"
    click_button "Send message"

    expect(page).to have_content "Your message has been sent correctly."
    expect(page).to have_content "Thank you for supporting my proposal"
    expect(page).to have_content "Please share it with others so we can make it happen!"
  end

  scenario "Send a notification (Active voter)", :no_js do
    proposal = create(:proposal)

    create(:user, :level_two, votables: [proposal], followables: [proposal])
    create_proposal_notification(proposal)

    expect(Notification.count).to eq(1)
  end

  scenario "Send a notification (Follower)", :no_js do
    proposal = create(:proposal)

    create(:user, :level_two, followables: [proposal])
    create_proposal_notification(proposal)

    expect(Notification.count).to eq(1)
  end

  scenario "Send a notification (Follower and Voter)", :no_js do
    proposal = create(:proposal)

    create(:user, followables: [proposal], votables: [proposal])
    create(:user, followables: [proposal])

    create_proposal_notification(proposal)

    expect(Notification.count).to eq(2)
  end

  scenario "Send a notification (Blocked voter)", :no_js do
    proposal = create(:proposal)
    voter = create(:user, :level_two, votables: [proposal])

    voter.block
    create_proposal_notification(proposal)

    expect(Notification.count).to eq(0)
  end

  scenario "Send a notification (Erased voter)", :no_js do
    proposal = create(:proposal)
    voter = create(:user, :level_two, votables: [proposal])

    voter.erase
    create_proposal_notification(proposal)

    expect(Notification.count).to eq(0)
  end

  scenario "Show notifications" do
    proposal = create(:proposal)

    create(:proposal_notification,
            proposal: proposal, title: "Hey guys",
            body: "Just wanted to let you know that...")
    create(:proposal_notification,
            proposal: proposal, title: "Another update",
            body: "We are almost there please share with your peoples!")

    visit proposal_path(proposal)
    click_link "Notifications (2)"

    expect(page).to have_content "Hey guys"
    expect(page).to have_content "Just wanted to let you know that..."

    expect(page).to have_content "Another update"
    expect(page).to have_content "We are almost there please share with your peoples!"
  end

  scenario "Message about receivers (Followers)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    7.times { create(:follow, :followed_proposal, followable: proposal) }

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This notification will be sent to 7 people and it will "\
                                 "be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal,
                                                     anchor: "comments"))
  end

  scenario "Message about receivers (Disctinct Followers and Voters)" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    7.times { create(:follow, :followed_proposal, followable: proposal) }
    7.times { create(:vote, votable: proposal, vote_flag: true) }

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This notification will be sent to 7 people and it will "\
                                 "be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal,
                                                     anchor: "comments"))
  end

  scenario "Message about receivers (Same Followers and Voters)" do
    author = create(:user)
    voter_follower = create(:user)

    proposal = create(:proposal, author: author, voters: [voter_follower], followers: [voter_follower])

    login_as(author)
    visit new_proposal_notification_path(proposal_id: proposal.id)

    expect(page).to have_content "This notification will be sent to 1 people and it will "\
                                 "be visible in the proposal's page"
    expect(page).to have_link("the proposal's page", href: proposal_path(proposal,
                                                     anchor: "comments"))
  end

  context "Permissions" do
    scenario "Link to send the message" do
      author = create(:user)
      proposal = create(:proposal, author: author)

      login_as(author)
      visit root_path

      click_link "My content"

      within("#proposal_#{proposal.id}") do
        click_link "Dashboard"
      end

      within("#side_menu") do
        click_link "Message to users"
      end

      expect(page).to have_link "Send notification to proposal followers"
    end

    scenario "Accessing form directly" do
      user = create(:user)
      author = create(:user)
      proposal = create(:proposal, author: author)

      login_as(user)
      visit new_proposal_notification_path(proposal_id: proposal.id)

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("You do not have permission to carry out the action")
    end
  end

  context "In-app notifications from the proposal's author" do
    scenario "Voters who are followed should receive a notification" do
      author = create(:user)
      proposal = create(:proposal, author: author)

      user1 = create(:user, votables: [proposal], followables: [proposal])
      user2 = create(:user, votables: [proposal], followables: [proposal])
      user3 = create(:user, votables: [proposal])

      login_as(author)
      visit root_path

      visit new_proposal_notification_path(proposal_id: proposal.id)

      fill_in "proposal_notification_title", with: "Thank you for supporting my proposal"
      fill_in "proposal_notification_body", with: "Please share it with "\
                                                  "others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      logout
      login_as user1
      visit root_path

      click_link "You have a new notification"

      expect(page).to have_css ".notification", count: 1

      click_link text: "There is one new notification on #{proposal.title}"

      expect(page).to have_current_path(proposal_path(proposal))

      logout
      login_as user2
      visit root_path

      click_link "You have a new notification"

      expect(page).to have_css ".notification", count: 1

      click_link text: "There is one new notification on #{proposal.title}"

      expect(page).to have_current_path(proposal_path(proposal))

      logout
      login_as user3
      visit root_path

      click_link "You don't have new notifications"

      expect(page).to have_css ".notification", count: 0
    end

    scenario "Followers should receive a notification" do
      author = create(:user)
      proposal = create(:proposal, author: author)

      user1 = create(:user, followables: [proposal])
      user2 = create(:user, followables: [proposal])
      user3 = create(:user)

      login_as author

      visit new_proposal_notification_path(proposal_id: proposal.id)

      fill_in "proposal_notification_title", with: "Thank you for supporting my proposal"
      fill_in "proposal_notification_body", with: "Please share it with "\
                                                  "others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      logout
      login_as user1
      visit root_path

      click_link "You have a new notification"

      expect(page).to have_css ".notification", count: 1

      click_link text: "There is one new notification on #{proposal.title}"

      expect(page).to have_current_path(proposal_path(proposal))

      logout
      login_as user2
      visit root_path

      click_link "You have a new notification"

      expect(page).to have_css ".notification", count: 1

      click_link text: "There is one new notification on #{proposal.title}"

      expect(page).to have_current_path(proposal_path(proposal))

      logout
      login_as user3
      visit root_path

      click_link "You don't have new notifications"

      expect(page).to have_css ".notification", count: 0
    end

    scenario "Proposal hidden" do
      author = create(:user)
      user = create(:user)
      proposal = create(:proposal, author: author, voters: [user], followers: [user])

      login_as(author)
      visit root_path

      visit new_proposal_notification_path(proposal_id: proposal.id)

      fill_in "proposal_notification_title", with: "Thank you for supporting my proposal"
      fill_in "proposal_notification_body", with: "Please share it with "\
                                                  "others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      proposal.hide

      logout
      login_as user
      visit root_path

      click_link "You have a new notification"

      expect(page).to have_css ".notification", count: 1
      expect(page).to have_content "This resource is not available anymore"
    end

    scenario "Proposal retired by author" do
      author = create(:user)
      user = create(:user)
      proposal = create(:proposal, author: author, voters: [user])

      login_as(author)
      visit root_path

      visit new_proposal_notification_path(proposal_id: proposal.id)
    end

    context "Group notifications" do
      before do
        Setting[:proposal_notification_minimum_interval_in_days] = 0
      end

      scenario "for the same proposal" do
        author = create(:user)
        proposal = create(:proposal, author: author)
        user = create(:user, followables: [proposal])

        login_as author

        3.times do
          visit new_proposal_notification_path(proposal_id: proposal.id)

          fill_in "Title", with: "Thank you for supporting my proposal"
          fill_in "Message", with: "Please share it with others so we can make it happen!"
          click_button "Send message"

          expect(page).to have_content "Your message has been sent correctly."
        end

        logout
        login_as user
        visit root_path

        click_link "You have 3 new notifications"

        expect(page).to have_css ".notification", count: 3
        expect(page).to have_content "There is one new notification on #{proposal.title}", count: 3
      end
    end
  end

  scenario "Error messages" do
    author = create(:user)
    proposal = create(:proposal, author: author)

    login_as(author)

    visit new_proposal_notification_path(proposal_id: proposal.id)
    click_button "Send message"

    expect(page).to have_content error_message
  end

  context "Limits" do
    scenario "Cannot send more than one notification within established interval" do
      author = create(:user)
      proposal = create(:proposal, author: author)

      login_as author

      visit new_proposal_notification_path(proposal_id: proposal.id)
      fill_in "Title", with: "Thank you for supporting my proposal"
      fill_in "Message", with: "Please share it with others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      visit new_proposal_notification_path(proposal_id: proposal.id)
      fill_in "Title", with: "Thank you again for supporting my proposal"
      fill_in "Message", with: "Please share it again with others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "You have to wait a minimum of 3 days between notifications"
      expect(page).not_to have_content "Your message has been sent correctly."
    end

    scenario "Use time traveling to make sure notifications can be sent after time interval" do
      author = create(:user)
      proposal = create(:proposal, author: author)

      login_as author

      visit new_proposal_notification_path(proposal_id: proposal.id)
      fill_in "Title", with: "Thank you for supporting my proposal"
      fill_in "Message", with: "Please share it with others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      travel_to(3.days.from_now + 1.second) do
        visit new_proposal_notification_path(proposal_id: proposal.id)
        fill_in "Title", with: "Thank you again for supporting my proposal"
        fill_in "Message", with: "Please share it again with others so we can make it happen!"
        click_button "Send message"

        expect(page).to have_content "Your message has been sent correctly."
        expect(page).not_to have_content "You have to wait a minimum of 3 days between notifications"
      end
    end
  end
end
