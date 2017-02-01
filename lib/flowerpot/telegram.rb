require "json"
require "net/http"

module Flowerpot
  class TelegramMessage
    attr_reader :username
    attr_reader :text

    def initialize(username, text)
      @username = username
      @text = text
    end
  end

  class TelegramClient
    # method used to get a username/chat_id mapping
    attr_accessor :chat_id_get

    # method used to set a username/chat_id mapping
    attr_accessor :chat_id_save

    # access is allowed to this to make it possible to initialize the buildin username/chat_id mapping
    # use this if you know what you do.
    attr_accessor :telegram_users

    # creates a new TelegramClient.
    # token is your telegram bot token
    # webhook_url is the url where the webhook can be called
    # chat_id_get is a proc used to retrieve a username/chat_id mapping
    # chat_id_save is a proc used to save a username/chat_id mapping
    def initialize(token, webhook_url=nil, chat_id_get=nil, chat_id_save=nil)
      @token = token
      @telegram_users = {}

      # set both methods for storing username/chat_id mappings
      # to the ones supplied as parameters or the internal ones
      if !chat_id_get.nil? && !chat_id_save.nil?
        @chat_id_get = chat_id_get
        @chat_id_save = chat_id_save
      else
        @chat_id_get = lambda do |username|
          @telegram_users[username]
        end
        @chat_id_save = lambda do |username, id|
          @telegram_users[username] = id
        end
      end

      # set the webhook if we have one
      if !webhook_url.nil?
        set_webhook(url)
      end
    end

    # set the webhook url with the telegram servers
    def set_webhook(url)
      send_request('setWebhook', {"url":url})
    end

    # delete the webhook url from the telegram servers
    def delete_webhook
      send_request('deleteWebhook', {})
    end

    # webhook has to be called with the body of a request to the webhook url.
    # see https://core.telegram.org/bots/api#setwebhook
    def webhook(body)
      x = JSON.parse(body)
      if !x.has_key?("message")
        raise "update isn't a message"
      end

      username = x["message"]["chat"]["username"]
      chat_id = x["message"]["chat"]["id"]

      @chat_id_save.call(username, chat_id)
    end

    # send a telegram message
    def send_message(message)
      chat_id = @chat_id_get.call(message.username)
      send_request("sendMessage", {"chat_id": chat_id, "text": message.text})
    end

    # send a request to telegram
    def send_request(method, params)
      uri = URI("https://api.telegram.org/bot#{@token}/#{method}")
      res = Net::HTTP.post_form(uri, params)
      if res.code != "200"
        raise "#{res.code} #{res.message}"
      end

      return res
    end
  end
end