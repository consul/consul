require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Consul
  class Application < Rails::Application
    config.load_defaults 5.2
  
    config.action_view.sanitized_allowed_attributes = ['href', 'title', 'target', 'style']
    
    # Keep belongs_to fields optional by default, because that's the way
    # Rails 4 models worked
    config.active_record.belongs_to_required_by_default = false

    # Use local forms with `form_with`, so it works like `form_for`
    config.action_view.form_with_generates_remote_forms = false

    # Keep disabling cache versioning until we verify it's compatible
    # with `:dalli_store` and with the way we cache stats
    config.active_record.cache_versioning = false

    # Keep using AES-256-CBC for message encryption in case it's used
    # in any CONSUL installations
    config.active_support.use_authenticated_message_encryption = false

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    available_locales = [
      "ar",
      "bg",
      "bs",
      "ca",
      "cs",
      "da",
      "de",
      "el",
      "en",
      "es",
      "es-PE",
      "eu",
      "fa",
      "fr",
      "gl",
      "he",
      "hr",
      "id",
      "it",
      "ka",
      "nl",
      "oc",
      "pl",
      "pt-BR",
      "ro",
      "ru",
      "sl",
      "sq",
      "so",
      "sr",
      "sv",
      "tr",
      "val",
      "zh-CN",
      "zh-TW"]
    config.i18n.available_locales = available_locales
    config.i18n.fallbacks = {
      "ca"    => "es",
      "es-PE" => "es",
      "eu"    => "es",
      "fr"    => "es",
      "gl"    => "es",
      "it"    => "es",
      "oc"    => "fr",
      "pt-BR" => "es",
      "val"   => "es"
    }

    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**[^custom]*", "*.{rb,yml}")]
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "custom", "**", "*.{rb,yml}")]

    config.after_initialize do
      Globalize.set_fallbacks_to_all_available_locales
    end

    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.assets.paths << Rails.root.join("vendor", "assets", "fonts")

    # Add lib to the autoload path
    config.autoload_paths << Rails.root.join("lib")
    config.time_zone = "Madrid"
    config.active_job.queue_adapter = :delayed_job

    # CONSUL specific custom overrides
    # Read more on documentation:
    # * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md
    # * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md
    #
    config.autoload_paths << "#{Rails.root}/app/components/custom"
    config.autoload_paths << "#{Rails.root}/app/controllers/custom"
    config.autoload_paths << "#{Rails.root}/app/models/custom"
    config.paths["app/views"].unshift(Rails.root.join("app", "views", "custom"))
  end
end

class Rails::Engine
  initializer :prepend_custom_assets_path, group: :all do |app|
    if self.class.name == "Consul::Application"
      %w[images fonts javascripts].each do |asset|
        app.config.assets.paths.unshift(Rails.root.join("app", "assets", asset, "custom").to_s)
      end
    end
  end
end

require "./config/application_custom"
