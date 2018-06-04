# frozen_string_literal: true

require 'sendgrid-ruby'
# Mailer
class Mailer
  include SendGrid
  def initialize(text_content, html_content, subject, email)
    @text    = text_content
    @html    = html_content
    @subject = subject
    @email   = email
  end

  def send
    mail = Mail.new
    mail.from = Email.new(email: 'no-reply@kencrocken.github.io')
    personalization = Personalization.new
    personalization.add_to(Email.new(email: @email))
    personalization.subject = @subject
    mail.add_personalization(personalization)
    mail.add_content(Content.new(type: 'text/plain', value: @text_content))
    mail.add_content(Content.new(type: 'text/html', value: @html_content))
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    response
  end
end
