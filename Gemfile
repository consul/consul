source "https://rubygems.org"

gem "rails", "5.1.7"

gem "acts-as-taggable-on", "~> 6.0.0"
gem "acts_as_votable", "~> 0.11.1"
gem "ahoy_matey", "~> 1.6.0"
gem "ancestry", "~> 3.0.7"
gem "apartment", "~> 2.2.1"
gem "audited", "~> 4.9.0"
gem "autoprefixer-rails", "~> 8.2.0"
gem "cancancan", "~> 2.3.0"
gem "ckeditor", "~> 4.3.0"
gem "cocoon", "~> 1.2.9"
gem "daemons", "~> 1.2.4"
gem "dalli", "~> 2.7.6"
gem "delayed_job_active_record", "~> 4.1.3"
gem "devise", "~> 4.7.1"
gem "devise-async", "~> 1.0.0"
gem "devise_security_extension", git: "https://github.com/phatworx/devise_security_extension.git" #, "~> 0.10"
gem "font-awesome-sass", "~> 5.8.1"
gem "foundation-rails", "~> 6.6.1.0"
gem "foundation_rails_helper", "~> 3.0.0"
gem "globalize", "~> 5.2.0"
gem "globalize-accessors", "~> 0.2.1"
gem "graphiql-rails", "~> 1.4.1"
gem "graphql", "~> 1.7.8"
gem "groupdate", "~> 3.2.0"
gem "initialjs-rails", "~> 0.2.0.8"
gem "invisible_captcha", "~> 0.10.0"
gem "jquery-fileupload-rails"
gem "jquery-rails", "~> 4.3.3"
gem "jquery-ui-rails", "~> 6.0.1"
gem "kaminari", "~> 1.2.1"
gem "newrelic_rpm", "~> 4.1.0.333"
gem "omniauth", "~> 1.9.0"
gem "omniauth-facebook", "~> 4.0.0"
gem "omniauth-google-oauth2", "~> 0.4.0"
gem "omniauth-rails_csrf_protection", "~> 0.1.2"
gem "omniauth-twitter", "~> 1.4.0"
gem "paperclip", "~> 5.2.1"
gem "paranoia", "~> 2.4.2"
gem "pg", "~> 0.21.0"
gem "pg_search", "~> 2.0.1"
gem "puma", "~> 4.3.5"
gem "recipient_interceptor", "~> 0.2.0"
gem "redcarpet", "~> 3.4.0"
gem "responders", "~> 2.4.0"
gem "rinku", "~> 2.0.2", require: "rails_rinku"
gem "rollbar", "~> 2.18.0"
gem "sassc-rails", "~> 2.1.2"
gem "savon", "~> 2.12.0"
gem "sitemap_generator", "~> 6.0.2"
gem "social-share-button", "~> 1.1"
gem "sprockets", "~> 3.7.2"
gem "translator-text", "~> 0.1.0"
gem "turbolinks", "~> 2.5.3"
gem "turnout", "~> 2.4.0"
gem "uglifier", "~> 4.1.2"
gem "whenever", "~> 0.10.0", require: false
gem "wicked_pdf", "~> 1.1.0"
gem "wkhtmltopdf-binary", "~> 0.12.4"

source "https://rails-assets.org" do
  gem "rails-assets-leaflet"
  gem "rails-assets-markdown-it", "~> 8.2.1"
end

group :development, :test do
  gem "bullet", "~> 5.9.0"
  gem "byebug", "~> 11.1.1"
  gem "factory_bot_rails", "~> 4.8.2"
  gem "faker", "~> 1.8.7"
  gem "i18n-tasks", "~> 0.9.29"
  gem "knapsack_pro", "~> 1.15.0"
  gem "launchy", "~> 2.4.3"
  gem "letter_opener_web", "~> 1.3.4"
  gem "spring", "~> 2.0.1"
  gem "spring-commands-rspec", "~> 1.0.4"
end

group :test do
  gem "capybara", "~> 3.29.0"
  gem "capybara-webmock", "~> 0.5.3"
  gem "coveralls", "~> 0.8.22", require: false
  gem "email_spec", "~> 2.2.0"
  gem "rspec-rails", "~> 3.8"
  gem "selenium-webdriver", "~> 3.141"
  gem "webdrivers", "~> 4.3.0"
end

group :development do
  gem "capistrano", "~> 3.10.1", require: false
  gem "capistrano-bundler", "~> 1.2", require: false
  gem "capistrano-rails", "~> 1.4.0", require: false
  gem "capistrano3-delayed-job", "~> 1.7.3"
  gem "capistrano3-puma", "~> 4.0.0"
  gem "database_cleaner", "~> 1.7.0"
  gem "erb_lint", require: false
  gem "github_changelog_generator", "~> 1.15.0"
  gem "mdl", "~> 0.5.0", require: false
  gem "rubocop", "~> 0.83.0", require: false
  gem "rubocop-performance", "~> 1.6.1", require: false
  gem "rubocop-rails", "~> 2.3.2", require: false
  gem "rubocop-rspec", "~> 1.35.0", require: false
  gem "rvm1-capistrano3", "~> 1.4.0", require: false
  gem "scss_lint", "~> 0.55.0", require: false
  gem "web-console", "~> 3.3.0"
end

eval_gemfile "./Gemfile_custom"
