require "rails_helper"

describe "Moderate comments" do
  scenario "Hide" do
    citizen = create(:user)
    moderator = create(:moderator)

    comment = create(:comment)

    login_as(moderator.user)
    visit debate_path(comment.commentable)

    within("#comment_#{comment.id}") do
      accept_confirm("Hide: Are you sure?") { click_link "Hide" }
      expect(page).to have_css(".comment .faded")
    end

    login_as(citizen)
    visit debate_path(comment.commentable)

    expect(page).to have_css(".comment", count: 1)
    expect(page).not_to have_content("This comment has been deleted")
    expect(page).not_to have_content("SPAM")
  end

  scenario "Can not hide own comment" do
    moderator = create(:moderator)
    comment = create(:comment, user: moderator.user)

    login_as(moderator.user)
    visit debate_path(comment.commentable)

    within("#comment_#{comment.id}") do
      expect(page).not_to have_link("Hide")
      expect(page).not_to have_link("Block author")
    end
  end

  scenario "Visit items with flagged comments" do
    moderator = create(:moderator)
    debate = create(:debate, title: "Debate with spam comment")
    proposal = create(:proposal, title: "Proposal with spam comment")
    create(:comment, commentable: debate, body: "This is SPAM comment on debate", flags_count: 2)
    create(:comment, commentable: proposal, body: "This is SPAM comment on proposal", flags_count: 2)

    login_as(moderator.user)
    visit moderation_comments_path

    expect(page).to have_content("Debate with spam comment")
    expect(page).to have_content("Proposal with spam comment")
    expect(page).to have_content("This is SPAM comment on debate")
    expect(page).to have_content("This is SPAM comment on proposal")

    click_link "Debate with spam comment"
    expect(page).to have_content("Debate with spam comment")
    expect(page).to have_content("This is SPAM comment on debate")

    visit moderation_comments_path

    click_link "Proposal with spam comment"
    expect(page).to have_content("Proposal with spam comment")
    expect(page).to have_content("This is SPAM comment on proposal")
  end

  describe "/moderation/ screen" do
    before do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    describe "moderate in bulk" do
      describe "When a comment has been selected for moderation" do
        let!(:comment) { create(:comment) }

        before do
          visit moderation_comments_path
          within(".menu.simple") do
            click_link "All"
          end

          within("#comment_#{comment.id}") do
            check "comment_#{comment.id}_check"
          end
        end

        scenario "Hide the comment" do
          accept_confirm("Hide comments: Are you sure?") do
            click_button "Hide comments"
          end

          expect(page).not_to have_css("#comment_#{comment.id}")

          click_link "Block users"
          fill_in "email or name of user", with: comment.user.email
          click_button "Search"

          within "tr", text: comment.user.name do
            expect(page).to have_link "Block"
          end
        end

        scenario "Block the user" do
          accept_confirm("Block authors: Are you sure?") do
            click_button "Block authors"
          end

          expect(page).not_to have_css("#comment_#{comment.id}")

          click_link "Block users"
          fill_in "email or name of user", with: comment.user.email
          click_button "Search"

          within "tr", text: comment.user.name do
            expect(page).to have_content "Blocked"
          end
        end

        scenario "Ignore the comment", :no_js do
          click_button "Mark as viewed"

          expect(comment.reload).to be_ignored_flag
          expect(comment.reload).not_to be_hidden
          expect(comment.user).not_to be_hidden
        end
      end

      scenario "select all/none" do
        create_list(:comment, 2)

        visit moderation_comments_path

        within(".js-check") { click_on "All" }

        expect(all("input[type=checkbox]")).to all(be_checked)

        within(".js-check") { click_on "None" }

        all("input[type=checkbox]").each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end

      scenario "remembering page, filter and order" do
        stub_const("#{ModerateActions}::PER_PAGE", 2)
        create_list(:comment, 4)

        visit moderation_comments_path(filter: "all", page: "2", order: "newest")

        accept_confirm("Mark as viewed: Are you sure?") { click_button "Mark as viewed" }

        expect(page).to have_link "Newest", class: "is-active"
        expect(page).to have_link "Most flagged"

        expect(page).to have_current_path(/filter=all/)
        expect(page).to have_current_path(/page=2/)
        expect(page).to have_current_path(/order=newest/)
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_comments_path
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("All")
      expect(page).to have_link("Marked as viewed")

      visit moderation_comments_path(filter: "all")
      within(".menu.simple") do
        expect(page).not_to have_link("All")
        expect(page).to have_link("Pending")
        expect(page).to have_link("Marked as viewed")
      end

      visit moderation_comments_path(filter: "pending_flag_review")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).not_to have_link("Pending")
        expect(page).to have_link("Marked as viewed")
      end

      visit moderation_comments_path(filter: "with_ignored_flag")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).to have_link("Pending")
        expect(page).not_to have_link("Marked as viewed")
      end
    end

    scenario "Filtering comments" do
      create(:comment, body: "Regular comment")
      create(:comment, :flagged, body: "Pending comment")
      create(:comment, :hidden, body: "Hidden comment")
      create(:comment, :flagged, :with_ignored_flag, body: "Ignored comment")

      visit moderation_comments_path(filter: "all")
      expect(page).to have_content("Regular comment")
      expect(page).to have_content("Pending comment")
      expect(page).not_to have_content("Hidden comment")
      expect(page).to have_content("Ignored comment")

      visit moderation_comments_path(filter: "pending_flag_review")
      expect(page).not_to have_content("Regular comment")
      expect(page).to have_content("Pending comment")
      expect(page).not_to have_content("Hidden comment")
      expect(page).not_to have_content("Ignored comment")

      visit moderation_comments_path(filter: "with_ignored_flag")
      expect(page).not_to have_content("Regular comment")
      expect(page).not_to have_content("Pending comment")
      expect(page).not_to have_content("Hidden comment")
      expect(page).to have_content("Ignored comment")
    end

    scenario "sorting comments" do
      flagged_comment = create(:comment, body: "Flagged comment", created_at: Time.current - 1.day, flags_count: 5)
      flagged_new_comment = create(:comment, body: "Flagged new comment", created_at: Time.current - 12.hours, flags_count: 3)
      newer_comment = create(:comment, body: "Newer comment", created_at: Time.current)

      visit moderation_comments_path(order: "newest")

      expect(flagged_new_comment.body).to appear_before(flagged_comment.body)

      visit moderation_comments_path(order: "flags")

      expect(flagged_comment.body).to appear_before(flagged_new_comment.body)

      visit moderation_comments_path(filter: "all", order: "newest")

      expect(newer_comment.body).to appear_before(flagged_new_comment.body)
      expect(flagged_new_comment.body).to appear_before(flagged_comment.body)

      visit moderation_comments_path(filter: "all", order: "flags")

      expect(flagged_comment.body).to appear_before(flagged_new_comment.body)
      expect(flagged_new_comment.body).to appear_before(newer_comment.body)
    end
  end
end
