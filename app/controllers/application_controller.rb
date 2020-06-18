require "application_responder"

class ApplicationController < ActionController::Base
  include GlobalizeFallbacks
  include HasFilters
  include HasOrders
  include AccessDeniedHandler

  default_form_builder ConsulFormBuilder
  protect_from_forgery with: :exception

  before_action :authenticate_http_basic, if: :http_basic_auth_site?

  before_action :ensure_signup_complete
  before_action :set_locale
  before_action :track_email_campaign
  before_action :set_return_url
  before_action :set_mailer_host

  check_authorization unless: :devise_controller?
  self.responder = ApplicationResponder

  layout :set_layout
  respond_to :html
  helper_method :current_budget

  private

    def authenticate_http_basic
      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.application.secrets.http_basic_username && password == Rails.application.secrets.http_basic_password
      end
    end

    def http_basic_auth_site?
      Rails.application.secrets.http_basic_auth
    end

    def verify_lock
      if current_user.locked?
        redirect_to account_path, alert: t("verification.alert.lock")
      end
    end

    def set_locale
      if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
        session[:locale] = params[:locale]
      end

      session[:locale] ||= I18n.default_locale

      locale = session[:locale]

      if current_user && current_user.locale != locale.to_s
        current_user.update(locale: locale)
      end

      I18n.locale = locale
      Globalize.locale = I18n.locale
    end

    def set_layout
      if devise_controller?
        "devise"
      else
        "application"
      end
    end

    def set_debate_votes(debates)
      @debate_votes = current_user ? current_user.debate_votes(debates) : {}
    end

    def set_proposal_votes(proposals)
      @proposal_votes = current_user ? current_user.proposal_votes(proposals) : {}
    end

    def set_comment_flags(comments)
      @comment_flags = current_user ? current_user.comment_flags(comments) : {}
    end

    def ensure_signup_complete
      if user_signed_in? && !devise_controller? && current_user.registering_with_oauth
        redirect_to finish_signup_path
      end
    end

    def verify_resident!
      unless current_user.residence_verified?
        redirect_to new_residence_path, alert: t("verification.residence.alert.unconfirmed_residency")
      end
    end

    def verify_verified!
      if current_user.level_three_verified?
        redirect_to(account_path, notice: t("verification.redirect_notices.already_verified"))
      end
    end

    def track_email_campaign
      if params[:track_id]
        campaign = Campaign.find_by(track_id: params[:track_id])
        ahoy.track campaign.name if campaign.present?
      end
    end

    def set_return_url
      if !devise_controller? && controller_name != "welcome" && is_navigational_format?
        store_location_for(:user, request.path)
      end
    end

    def set_default_budget_filter
      if @budget&.balloting? || @budget&.publishing_prices?
        params[:filter] ||= "selected"
      elsif @budget&.finished?
        params[:filter] ||= "winners"
      end
    end

    def current_budget
      Budget.current
    end

    def redirect_with_query_params_to(options, response_status = {})
      path_options = { controller: params[:controller] }.merge(options).merge(only_path: true)
      path = url_for(request.query_parameters.merge(path_options))

      redirect_to path, response_status
    end

    def set_mailer_host
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
      ActionMailer::Base.asset_host = request.protocol + request.host_with_port
    end
end
