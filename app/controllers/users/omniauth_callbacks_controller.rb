class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter_setup
    tenant = Tenant.current
    unless tenant.nil?
      request.env["omniauth.strategy"].options[:consumer_key] = tenant.twitter_key
      request.env["omniauth.strategy"].options[:consumer_secret] = tenant.twitter_secret
    end
    render body: "Omniauth Twitter setup phase.", status: 404
  end

  def facebook_setup
    tenant = Tenant.current
    unless tenant.nil?
      request.env["omniauth.strategy"].options[:client_id] = tenant.facebook_key
      request.env["omniauth.strategy"].options[:client_secret] = tenant.facebook_secret
    end
    render body: "Omniauth Facebook setup phase.", status: 404
  end

  def twitter
    sign_in_with :twitter_login, :twitter
  end

  def facebook
    sign_in_with :facebook_login, :facebook
  end

  def google_oauth2
    sign_in_with :google_login, :google_oauth2
  end

  def wordpress_oauth2
    sign_in_with :wordpress_login, :wordpress_oauth2
  end

  def after_sign_in_path_for(resource)
    if resource.registering_with_oauth
      finish_signup_path
    else
      super(resource)
    end
  end

  private

    def sign_in_with(feature, provider)
      raise ActionController::RoutingError.new("Not Found") unless Setting["feature.#{feature}"]

      auth = request.env["omniauth.auth"]

      identity = Identity.first_or_create_from_oauth(auth)
      @user = current_user || identity.user || User.first_or_initialize_for_oauth(auth)

      if save_user
        identity.update!(user: @user)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider.to_s.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = auth
        redirect_to new_user_registration_path
      end
    end

    def save_user
      @user.save || @user.save_requiring_finish_signup
    end
end
