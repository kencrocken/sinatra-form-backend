# frozen_string_literal: true

require './mailer/mailer'
# Response helpers
module ResponseHelpers
  def send_email(params, ipaddress)
    subjects = [
      "[kencrocken.github.io] New Message from #{params['name']} - #{params['email']}",
      '[kencrocken.github.io] Thanks!'
    ]
    @params = params
    @ipaddress = ipaddress
    thanks = Mailer.new(thanks_text(params), erb(:thanks), subjects[1], params['email'])
    email = Mailer.new(email_text(params, ipaddress), erb(:email), subjects[0], 'kcrocken@gmail.com')
    email.send
    thanks.send
  end

  def handle_response(response, submitted_values)
    if response.body['errors']
      errors = JSON.parse(response.body)
      return { response: response.status_code, errors: errors['errors'], ok: false }.to_json
    end
    { response: response.status_code, submitted_values: submitted_values, message: 'success', ok: true }.to_json
  end

  private

  def email_text(params, ipaddress)
    %(
      You have received the following:
      Email:  #{params['email']}
      Name:  #{params['name']}
      Message: #{params['message']}
      From: #{ipaddress}
    )
  end

  def thanks_text(params)
    %(
      Thanks for getting in touch!
      I'll contact you soon at the email provided:#{params['email']}
      Feel free to reach out if you have any additional questions.
      https://www.linkedin.com/in/kenneth-crocken-aaa91417/

      Thanks again,

      Ken
    )
  end
end
