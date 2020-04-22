require "rails_helper"

describe Users::RegistrationsController do
  describe "POST check_username" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when username is available" do
      it "returns true with no error message" do
        get :check_username, params: { username: "available username" }

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be true
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.username_is_available")
      end
    end

    context "when username is not available" do
      it "returns false with an error message" do
        user = create(:user)
        get :check_username, params: { username: user.username }

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be false
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.username_is_not_available")
      end
    end
  end

  describe "POST check_email" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when email is valid" do
      it "returns true with no error message" do
        get :check_email, params: { email: "test@test.com" }

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be true
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.email_is_valid")
      end
    end

    context "when email is invalid" do
      it "returns false with an error message" do
        get :check_email, params: { email: "test@test" }

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be false
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.email_is_invalid")
      end
    end
  end
end
