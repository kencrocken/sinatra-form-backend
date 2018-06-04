require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'sendgrid-ruby'
include SendGrid

# APP_ROOT = File.join(File.dirname(__FILE__), '..')

# set :root, APP_ROOT
set :bind, '0.0.0.0'

configure do
  enable :cross_origin
end

before do
  if request.body.read(1)
    request.body.rewind
    @values = JSON.parse request.body.read
  end
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*'
end

def send_email(params, ipaddress)
  puts params
  @params = params
  @ipaddress = ipaddress
  textMessage = %{
    You have received the following:
    Email:  #{ params['email'] }
    Name:  #{ params['name'] }
    Message: #{ params['message'] }
    From: #{ ipaddress }
  }
  mail = Mail.new
  mail.from = Email.new(email: 'no-reply@kencrocken.github.io')
  to = Email.new(email: 'kcrocken@gmail.com')
  subject = "[kencrocken.github.io] New Message from #{params['name']} - #{params['email']}"
  html_content = Content.new(type: 'text/html', value: erb(:email))
  text_content = Content.new(type: 'text/plain', value: textMessage)
  personalization = Personalization.new
  personalization.add_to(Email.new(email: 'kcrocken@gmail.com'))
  personalization.subject = subject
  # mail = Mail.new(from, subject, to, text_content, html_content)
  mail.add_personalization(personalization)
  mail.add_content(Content.new(type: 'text/plain', value: textMessage))
  mail.add_content(Content.new(type: 'text/html', value: erb(:email)))

  sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  response = sg.client.mail._('send').post(request_body: mail.to_json)
  puts response.status_code
  puts response.body
  puts response.headers
end
def send_thanks( params )
  @params = params
  textMessage = %{
    Thanks for getting in touch!
    I'll contact you soon at the email provided:#{ params['email'] }
    Feel free to reach out if you have any additional questions.
    https://www.linkedin.com/in/kenneth-crocken-aaa91417/

    Thanks again,

    Ken
  }
  mail = Mail.new
  mail.from = Email.new(email: 'no-reply@kencrocken.github.io')
  subject = "[kencrocken.github.io] Thanks!"
  personalization = Personalization.new
  personalization.add_to(Email.new(email: params['email']))
  personalization.subject = subject
  mail.add_personalization(personalization)
  mail.add_content(Content.new(type: 'text/plain', value: textMessage))
  mail.add_content(Content.new(type: 'text/html', value: erb(:thanks)))

  sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  response = sg.client.mail._('send').post(request_body: mail.to_json)
  puts response.status_code
  puts response.body
  puts response.headers

end

get '/' do
  { message: 'success', ok: true }.to_json
end
post '/' do
  if @values.empty?
    status 500
    response = { message: 'values are empty', ok: false }
    return response.to_json
  end

  begin
    send_email(@values, @env['REMOTE_ADDR'])
    send_thanks( @values )
    @sent = true
    return { submitted_values: @values, message: 'success', ok: true }.to_json
  rescue StandardError => e
    status 500
    puts e.inspect
    @failure = { message: 'Ooops, it looks like something went wrong while attempting to send your email. Mind trying again now or later? :)', ok: false }
    return @failure.to_json
  end
end

options '*' do
  response.headers['Allow'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  200
end
