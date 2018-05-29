require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'sendgrid-ruby'
include SendGrid

APP_ROOT = File.join(File.dirname(__FILE__), '..')

set :root, APP_ROOT
set :bind, '0.0.0.0'

configure do
  enable :cross_origin
end

before do
  if request.body.size > 0
    request.body.rewind
    @values = JSON.parse request.body.read
  end
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['POST']
end

def send_email(params, ipaddress)
  puts ENV['SENDGRID_API_KEY']
  puts params['name']
  puts params['email']
  puts params['message']
  puts ipaddress
  message = params['message']
  puts message
  from = Email.new(email: 'no-reply@kencrocken.github.io')
  to = Email.new(email: 'kcrocken@gmail.com')
  subject = 'Sending with SendGrid is Fun'
  content = Content.new(type: 'text/plain', value: message)
  mail = Mail.new(from, subject, to, content)

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
  unless !@values.empty?
    status 500
    response = { message: 'values are empty', ok: false }
    return response.to_json
  end

  begin
    send_email(@values, @env['REMOTE_ADDR'])
    @sent = true
    return @values.to_json
  rescue Exception => e
    puts e
    status 500
    @failure = {ok: false, message: 'Ooops, it looks like something went wrong while attempting to send your email. Mind trying again now or later? :)'}
    return @failure.to_json
  end

end

options '*' do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end
