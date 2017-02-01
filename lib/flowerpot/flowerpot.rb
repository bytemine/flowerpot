require "json"
require "net/http"

module Flowerpot
  class Message
    attr_accessor :text
  end

  class Flowerpot
    attr_reader :telegram
    attr_reader :cmtelecom
    attr_reader :twilio

    def initialize(config)
      if config[:telegram]
        @telegram = TelegramClient.new(config[:telegram][:token], config[:telegram][:webhook_url],config[:telegram][:chat_id_get], config[:telegram][:chat_id_save])
      end

      if config[:cmtelecom]
        @cmtelecom = CMTelecomClient.new(config[:cmtelecom][:token], config[:cmtelecom][:from])
      end

      if config[:twilio]
        @twilio = TwilioClient.new(config[:twilio][:account_sid], config[:twilio][:auth_token], config[:twilio][:from])
      end
    end

    def transports
      return {telegram: @telegram != nil, cmtelecom: @cmtelecom != nil, twilio: @twilio != nil}
    end

    def send_message(message)
      case
      when message.class == TelegramMessage
        if @telegram
          @telegram.send_message(message)
          return
        end
      when message.class == CMTelecomMessage
        if @cmtelecom
          @cmtelecom.send_message(message)
          return
        end
      when message.class == TwilioMessage
        if @twilio
          @twilio.send_message(message)
          return
        end
      end

      raise "unknown message type"
    end
  end
end
