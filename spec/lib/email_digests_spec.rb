require "rails_helper"

describe EmailDigest do
  describe "notifications" do
    it "returns notifications for a user" do
      user1 = create(:user)
      user2 = create(:user)

      proposal_notification = create(:proposal_notification)
      notification1 = create(:notification, notifiable: proposal_notification, user: user1)
      notification2 = create(:notification, notifiable: proposal_notification, user: user2)

      email_digest = EmailDigest.new(user1)

      expect(email_digest.notifications).to eq [notification1]
      expect(email_digest.notifications).not_to include(notification2)
    end

    it "returns only proposal notifications" do
      user = create(:user)

      notification1 = create(:notification, :for_proposal_notification, user: user)
      notification2 = create(:notification, :for_comment, user: user)

      email_digest = EmailDigest.new(user)

      expect(email_digest.notifications).to eq [notification1]
      expect(email_digest.notifications).not_to include(notification2)
    end
  end

  describe "pending_notifications?" do
    let(:user) { create(:user) }

    it "returns true when notifications have not been emailed" do
      create(:notification, :for_proposal_notification, user: user)

      email_digest = EmailDigest.new(user)
      expect(email_digest.pending_notifications?).to be
    end

    it "returns false when notifications have been emailed" do
      create(:notification, :for_proposal_notification, user: user, emailed_at: Time.current)

      email_digest = EmailDigest.new(user)
      expect(email_digest.pending_notifications?).not_to be
    end

    it "returns false when there are no notifications for a user" do
      email_digest = EmailDigest.new(user)
      expect(email_digest.pending_notifications?).not_to be
    end
  end

  describe "deliver" do
    let(:user) { create(:user) }

    it "delivers email if notifications pending" do
      create(:notification, :for_proposal_notification, user: user)

      reset_mailer
      email_digest = EmailDigest.new(user)
      email_digest.deliver(Time.current)

      email = open_last_email
      expect(email).to have_subject("Proposal notifications in CONSUL")
    end

    it "does not deliver email if no notifications pending" do
      create(:notification, :for_proposal_notification, user: user, emailed_at: Time.current)

      reset_mailer
      email_digest = EmailDigest.new(user)
      email_digest.deliver(Time.current)

      expect(all_emails).to be_empty
    end
  end

  describe "mark_as_emailed" do
    it "marks notifications as emailed" do
      user1 = create(:user)
      user2 = create(:user)

      proposal_notification = create(:proposal_notification)
      notification1 = create(:notification, notifiable: proposal_notification, user: user1)
      notification2 = create(:notification, notifiable: proposal_notification, user: user1)
      notification3 = create(:notification, notifiable: proposal_notification, user: user2)

      expect(notification1.emailed_at).not_to be
      expect(notification2.emailed_at).not_to be
      expect(notification3.emailed_at).not_to be

      email_digest = EmailDigest.new(user1)
      email_digest.mark_as_emailed

      notification1.reload
      notification2.reload
      notification3.reload
      expect(notification1.emailed_at).to be
      expect(notification2.emailed_at).to be
      expect(notification3.emailed_at).not_to be
    end

    it "resets the failed_email_digests_count flag" do
      user1 = create(:user, failed_email_digests_count: 0)
      user2 = create(:user, failed_email_digests_count: 3)

      email_digest_1 = EmailDigest.new(user1)
      email_digest_2 = EmailDigest.new(user2)
      email_digest_1.mark_as_emailed
      email_digest_2.mark_as_emailed

      expect(user1.failed_email_digests_count).to eq(0)
      expect(user2.failed_email_digests_count).to eq(0)
    end
  end

  describe "#valid_email?" do
    it "returns a MatchData if email is valid" do
      user = create(:user, email: "valid_email@email.com")

      email_digest = EmailDigest.new(user)
      expect(email_digest.valid_email?).to be_a(MatchData)
    end

    it "returns nil if email is invalid" do
      user = create(:user, :skip_validate, email: "invalid_email@email..com")

      email_digest = EmailDigest.new(user)
      expect(email_digest.valid_email?).to be(nil)
    end

    it "returns false if email does not exist" do
      user = create(:user)
      user.email = nil

      email_digest = EmailDigest.new(user)
      expect(email_digest.valid_email?).to be(false)
    end
  end
end
