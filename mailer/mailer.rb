# frozen_string_literal: true

require 'sendgrid-ruby'
# Mailer
class Mailer
  include SendGrid
  def initialize(text_content, html_content, subject, to_address)
    @text    = text_content
    @html    = html_content
    @subject = subject
    @to      = to_address
    @from    = 'no-reply@kencrocken.github.io'
  end

  def send
    mail = Mail.new
    mail.from = Email.new(email: @from)
    personalization = Personalization.new
    personalization.add_to(Email.new(email: @to))
    personalization.subject = @subject
    mail.add_personalization(personalization)

    mail.add_content(Content.new(type: 'text/plain', value: @text))
    mail.add_content(Content.new(type: 'text/html', value: @html))
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.headers
    puts response.body
    response
  end
end
