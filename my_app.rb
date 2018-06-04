require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'sendgrid-ruby'
require_relative 'mailer/mailer'
include SendGrid

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
  headers 'Access-Control-Allow-Origin' => 'https://peaceful-easley-3144c1.netlify.com/'
end

def send_email(params, ipaddress)
  @params = params
  @ipaddress = ipaddress

  text_message_0 = %(
    You have received the following:
    Email:  #{params['email']}
    Name:  #{params['name']}
    Message: #{params['message']}
    From: #{ipaddress}
  )
  text_message_1 = %(
    Thanks for getting in touch!
    I'll contact you soon at the email provided:#{params['email']}
    Feel free to reach out if you have any additional questions.
    https://www.linkedin.com/in/kenneth-crocken-aaa91417/

    Thanks again,

    Ken
  )
  subjects = [
    "[kencrocken.github.io] New Message from #{params['name']} - #{params['email']}",
    "[kencrocken.github.io] Thanks!"
  ]

  thanks = Mailer.new(text_message_0, erb(:thanks), subjects[1], params['email'])
  thanks.send()
  puts thanks.inspect
  email = Mailer.new(text_message_1, erb(:email), subjects[0], 'kcrocken@gmail.com')
  email.send()
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

    # send_thanks( @values )
    @sent = send_email(@values, @env['REMOTE_ADDR'])
    # puts @sent.inspect
    return { response: @sent.status_code, submitted_values: @values, message: 'success', ok: true }.to_json
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
