class DeviseMailer < Devise::Mailer
  helper :application, :settings
  include Devise::Controllers::UrlHelpers
  default template_path: "devise/mailer"
  default reply_to: ->(*) { Setting.full_email_address }

  def default_url_options
    dup = Rails.application.config.action_mailer.default_url_options
    if Apartment::Tenant.current != "public"
      tenant = Tenant.find_by(subdomain: Apartment::Tenant.current)
      dup = { host: "#{tenant.subdomain}.#{tenant.server_name}" }
    end

    dup
  end

  def asset_host
    ah = Rails.application.config.action_mailer.asset_host
    if Apartment::Tenant.current != "public"
      tenant = Tenant.find_by(subdomain: Apartment::Tenant.current)
      ah = "#{tenant.subdomain}.#{tenant.server_name}"
    end

    ah
  end

  protected

    def devise_mail(record, action, opts = {})
      I18n.with_locale record.locale do
        super(record, action, opts)
      end
    end
end
