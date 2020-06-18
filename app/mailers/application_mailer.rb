class ApplicationMailer < ActionMailer::Base
  helper :settings
  helper :application
  default from: ->(*) { Setting.full_email_address }
  default reply_to: ->(*) { Setting.full_email_address }
  layout "mailer"
end
