require "rails_helper"

describe DeviseMailer do
  describe "#confirmation_instructions" do
    it "sends emails in the user's locale" do
      user = create(:user, locale: "es")

      email = I18n.with_locale :en do
        DeviseMailer.confirmation_instructions(user, "ABC")
      end

      expect(email.subject).to include("confirmación")
    end

    it "reads the from address at runtime" do
      Setting["mailer_from_name"] = "New organization"
      Setting["mailer_from_address"] = "new@consul.dev"

      email = DeviseMailer.confirmation_instructions(create(:user), "ABC")

      expect(email).to deliver_from "New organization <new@consul.dev>"
    end
  end
end
