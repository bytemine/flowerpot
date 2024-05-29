require "json"
require "net/http"

module Flowerpot
  class CMTelecomMessage
    attr_accessor :from
    attr_accessor :token

    def initialize(number, text, from=nil)
      @number = number
      @text = text
      @from = from
    end

    def valid_from?
      if /^[0-9]{1,15}$/.match(@from) == nil and /^[0-9a-zA-Z]{1,11}$/.match(@from) == nil
        return false
      end
      return true
    end

    def valid_length?
      if @text.length > 160 or @text.length < 1
        return false
      end
      return true
    end

    def valid_number?
      if /^0{2}[0-9]+$/.match(@number) == nil
        return false
      end
      return true
    end

    def valid_token?
      if /^[0-9a-zA-Z]{8}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{12}$/.match(@token) == nil
        return false
      end
      return true
    end

    def to_json(*a)
      if !valid_from?
        raise "from must not be empty and either shorter than 16 digits or shorter than 12 characters"
      end

      if !valid_length?
        raise "text must not be empty or longer than 160 characters"
      end

      if !valid_number?
        raise "number must not be empty, start with 00 and only consist of numerals"
      end

      if !valid_token?
        raise "invalid api token"
      end

      return {
        messages: {
          authentication: {
            producttoken: @token
          },
          msg: [
            {
              from: @from,
              to: [ { number: @number }],
              body: { content: @text }
            }
          ]
        }
      }.to_json(*a)
    end
  end

  class CMTelecomClient
    def initialize(token, from)
      if token.length == 0
        raise "token must be set"
      end

      if from.length == 0
        raise "default from must be set"
      end

      @token = token
      @from = from
    end

    def send_message(message)
      if message.from == nil
        message.from = @from
      end

      message.token = @token
      
      uri = URI('https://gw.cmtelecom.com/v1.0/message')
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = message.to_json
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
      end
      
      if res.code != "200"
        raise "#{res.code} #{res.message}"
      end
    end
  end
end
