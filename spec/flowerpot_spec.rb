require "spec_helper"

describe Flowerpot do
  it "has a version number" do
    expect(Flowerpot::VERSION).not_to be nil
  end

  describe Flowerpot::TelegramClient do
    it "receives a webhook update and saves the username/chat_id combination with custom handlers" do
      chat_id = 0

      g = lambda do |username|
        return chat_id
      end

      s = lambda do |username, id|
        chat_id = id
      end

      x = Flowerpot::TelegramClient.new("test", nil, g, s)

      x.webhook(%q[{"message":{"chat":{"username":"user","id":1234}}}])
      expect(chat_id).to eq(1234)
    end

    it "receives a webhook update and saves the username/chat_id combination with builtin hashmap" do
      x = Flowerpot::TelegramClient.new("test", nil, nil, nil)

      x.webhook(%q[{"message":{"chat":{"username":"user","id":1234}}}])
      expect(x.telegram_users["user"]).to eq(1234)
    end
  end

  describe Flowerpot::CMTelecomClient do
  end

  describe Flowerpot::CMTelecomMessage do
    it "is invalid if text is longer than 160 chars" do
      msg = Flowerpot::CMTelecomMessage.new("", "x"*161)
      expect(msg.valid_length?).to eq(false)
    end

    it "is valid if text is shorter than 161 chars" do
      msg = Flowerpot::CMTelecomMessage.new("", "x"*160)
      expect(msg.valid_length?).to eq(true)
    end

    it "is invalid if from is a number longer than 15 digits" do
      msg = Flowerpot::CMTelecomMessage.new("", "", "1234567890123456")
      expect(msg.valid_from?).to eq(false)
    end

    it "is invalid if from is alphanumeric and longer than 11 chars" do
      msg = Flowerpot::CMTelecomMessage.new("", "", "abcdefghijkL")
      expect(msg.valid_from?).to eq(false)
    end

    it "is invalid if number consists not only of numerals" do
      msg = Flowerpot::CMTelecomMessage.new("00123FOOBAR", "")
      expect(msg.valid_number?).to eq(false)
    end

    it "is valid if number consists only of numerals" do
      msg = Flowerpot::CMTelecomMessage.new("00123456789", "")
      expect(msg.valid_number?).to eq(true)
    end

    it "is invalid if number does not start with 00" do
      msg = Flowerpot::CMTelecomMessage.new("99999999999", "")
      expect(msg.valid_number?).to eq(false)
    end

    it "is valid if number does start with 00" do
      msg = Flowerpot::CMTelecomMessage.new("00000000000", "")
      expect(msg.valid_number?).to eq(true)
    end

    it "raises an exception if marshalled to json with invalid settings" do
      expect { Flowerpot::CMTelecomMessage.new("0012345", "x"*161, "from").to_json }.to raise_error "text must not be empty or longer than 160 characters"
      expect { Flowerpot::CMTelecomMessage.new("0012345", "text", "1234567890123456").to_json }.to raise_error "from must not be empty and either shorter than 16 digits or shorter than 12 characters"
      expect { Flowerpot::CMTelecomMessage.new("0012345", "text", "abcdefghijkL").to_json }.to raise_error "from must not be empty and either shorter than 16 digits or shorter than 12 characters"
      expect { Flowerpot::CMTelecomMessage.new("0012345FOOBAR", "text", "from").to_json }.to raise_error "number must not be empty, start with 00 and only consist of numerals"
    end

    it "raises no exception if marshalled to json with valid settings" do
      x = Flowerpot::CMTelecomMessage.new("0012345", "x"*160, "from")
      x.token = "00000000-0000-0000-0000-000000000000"
      expect(x.to_json).to be_a(String)
    end
  end

  describe Flowerpot::TwilioClient do
  end

  describe Flowerpot::TwilioMessage do
    it "is invalid if the number does not start with +xx or 00xx" do
      expect(Flowerpot::TwilioMessage.new("123456789", "test").valid_number?).to eq(false)
    end

    it "is valid if the number is in a valid international format" do
      expect(Flowerpot::TwilioMessage.new("+123456789", "test").valid_number?).to eq(true)
      expect(Flowerpot::TwilioMessage.new("00123456789", "test").valid_number?).to eq(true)
    end
  end
end
