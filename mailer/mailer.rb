# frozen_string_literal: true

require 'sendgrid-ruby'
# Mailer
class Mailer
  include SendGrid

  attr_accessor :text, :html, :subject, :to, :from

  def initialize(text_content, html_content, subject, to_address)
    @text    = text_content
    @html    = html_content
    @subject = subject
    @to      = to_address
    @from    = 'no-reply@kencrocken.github.io'
  end

  def send
    mail = build_mail
    response = send_mail(mail)
    response
  end

  private

  def build_mail
    mail = Mail.new
    mail.from = Email.new(email: @from)
    mail.add_personalization(handle_personalization())
    mail.add_content(Content.new(type: 'text/plain', value: @text))
    mail.add_content(Content.new(type: 'text/html', value: @html))
    mail
  end

  def handle_personalization
    personalization = Personalization.new
    personalization.add_to(Email.new(email: @to))
    personalization.subject = @subject
    personalization
  end

  def send_mail(mail)
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._('send').post(request_body: mail.to_json)
  end
end
