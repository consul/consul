unless Rails.env.test?
  require "database_cleaner"
  DatabaseCleaner.clean_with :truncation
end
@logger = Logger.new(STDOUT)
@logger.formatter = proc do |_severity, _datetime, _progname, msg|
                      msg unless @avoid_log
                    end

def section(section_title)
  @logger.info section_title
  yield
  log(" ✅")
end

def log(msg)
  @logger.info "#{msg}\n"
end

def random_locales
  [I18n.default_locale, *I18n.available_locales.sample(4)].uniq
end

require_relative "dev_seeds/settings"
require_relative "dev_seeds/geozones"
require_relative "dev_seeds/users"
require_relative "dev_seeds/tags_categories"
require_relative "dev_seeds/debates"
require_relative "dev_seeds/proposals"
require_relative "dev_seeds/budgets"
require_relative "dev_seeds/comments"
require_relative "dev_seeds/votes"
require_relative "dev_seeds/flags"
require_relative "dev_seeds/hiddings"
require_relative "dev_seeds/banners"
require_relative "dev_seeds/polls"
require_relative "dev_seeds/communities"
require_relative "dev_seeds/legislation_processes"
require_relative "dev_seeds/newsletters"
require_relative "dev_seeds/notifications"
require_relative "dev_seeds/tenants"
require_relative "dev_seeds/widgets"
require_relative "dev_seeds/admin_notifications"
require_relative "dev_seeds/legislation_proposals"
require_relative "dev_seeds/milestones"
require_relative "dev_seeds/pages"

log "All dev seeds created successfuly 👍"
