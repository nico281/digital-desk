class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "Digital Desk <no-reply@digitaldesk.com>")
  layout "mailer"
end
