# Flowerpot

Flowerpot is a wrapper for various messaging channels. Currently Telegram, CM Telecom and Twilio are supported.

## Telegram

    require "flowerpot"

    x = Flowerpot::Flowerpot.new({telegram: {token: "telegram token", webhook_url: "url to webhook", chat_id_get: ProcToGetChatId, chat_id_save: ProcToSaveChatId}})

    # serve the url you have configured as webhook_url somehow. there, call x.telegram.webhook with the request body.
    # chat_id_get and chat_id_save must either be nil or procs to get and save username/chat_id mappings to your own storage.
    # the specs for Flowerpot::TelegramClient give a little example for this.

    # to send messages, the user must have written you previously so that the chat_id is known.
    x.send_message(Flowerpot::TelegramMessage.new("receiving_username", "text"))

## CM Telecom

    require "flowerpot"

    x = Flowerpot::Flowerpot.new({cmtelecom: {token: "cm telecom token", from: "sender id"}})
    x.send_message(Flowerpot::CMTelecomMessage.new("receiving number", "text"))

## Twilio

    require "flowerpot"

    x = Flowerpot::Flowerpot.new({twilio: {account_sid: "twilio account sid", auth_token: "twilio auth token", from: "sender id"}})
    x.send_message(Flowerpot::TwilioMessage.new("receiving number", "text"))

## Query configured transports

The usable (configured) transports can be queried with the `transports` method of `Flowerpot::Flowerpot`.
