require 'twilio-ruby'

module Flowerpot
  class TwilioMessage
    attr_reader :number
    attr_reader :text
    
    def initialize(number, text)
      @number = number
      @text = text
    end

    def valid_number?
      if /^0{2}[0-9]+$/.match(@number) == nil and /^\+[0-9]+$/.match(@number) == nil
        return false
      end
      return true
    end
  end

  class TwilioClient
    def initialize(account_sid, auth_token, from)
      @from = from
      @client = Twilio::REST::Client.new account_sid, auth_token
    end

    def send_message(message)
      if !message.valid_number?
        raise "number must be in a valid international format"
      end
      @client.messages.create(from: @from, to: message.number, body: message.text)
    end
  end
end