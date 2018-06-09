# frozen_string_literal: true

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require_relative 'helpers/response'

helpers ResponseHelpers

configure do
  enable :cross_origin
end

before do
  if request.body.read(1)
    request.body.rewind
    @values = JSON.parse request.body.read
  end
  content_type :json
  headers 'Access-Control-Allow-Origin' => ENV['SITE_LIST']
end

get '/' do
  { message: 'success', ok: true }.to_json
end

post '/' do
  begin
    if @values.empty?
      status 400
      return { message: 'values are empty', ok: false }.to_json
    end
    response = send_email(@values, @env['REMOTE_ADDR'])
    status response.status_code
    handle_response(response, @values)
  rescue StandardError => e
    status 500
    puts e.inspect
    @failure = { message: 'Ooops, it looks like something went wrong while attempting to send your email. Mind trying again now or later? :)', ok: false }
    @failure.to_json
  end
end

options '*' do
  response.headers['Allow'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  200
end
