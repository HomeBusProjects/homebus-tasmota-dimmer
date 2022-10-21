require 'spec_helper'

require 'homebus-tasmota-dimmer/version'
require 'homebus-tasmota-dimmer/options'
require 'homebus-tasmota-dimmer/app'

require 'homebus/config'

class TestHomebusTasmotaDimmer < HomebusTasmotaDimmer::App
  # override config so that the superclasses don't try to load it during testing
  def initialize(options)
    @config = Hash.new
    @config = Homebus::Config.new

    @config.login_config = {
                            "default_login": 0,
                            "next_index": 1,
                            "homebus_instances": [
                                      {
                                        "provision_server": "https://homebus.org",
                                       "email_address": "example@example.com",
                                       "token": "XXXXXXXXXXXXXXXX",
                                       "index": 0
                                      }
                                    ]
    }

    @store = Hash.new
    super
  end
end

describe HomebusTasmotaDimmer do
  context "Version number" do
    it "Has a version number" do
      expect(HomebusTasmotaDimmer::VERSION).not_to be_nil
      expect(HomebusTasmotaDimmer::VERSION.class).to be String
    end
  end 
end

describe HomebusTasmotaDimmer::Options do
  context "Methods" do
    options = HomebusTasmotaDimmer::Options.new

    it "Has a version number" do
      expect(options.version).not_to be_nil
      expect(options.version.class).to be String
    end

    it "Uses the VERSION constant" do
      expect(options.version).to eq(HomebusTasmotaDimmer::VERSION)
    end

    it "Has a name" do
      expect(options.name).not_to be_nil
      expect(options.name.class).to be String
    end

    it "Has a banner" do
      expect(options.banner).not_to be_nil
      expect(options.banner.class).to be String
    end
  end
end

describe TestHomebusTasmotaDimmer do
  context "Methods" do
    options = HomebusTasmotaDimmer::Options.new
    app = HomebusTasmotaDimmer::App.new(options)

    it "Has a name" do
      expect(app.name).not_to be_nil
      expect(app.name.class).to be String
    end

    it "Consumes" do
      expect(app.consumes).not_to be_nil
      expect(app.consumes.class).to be Array
    end

    it "Publishes" do
      expect(app.publishes).not_to be_nil
      expect(app.publishes.class).to be Array
    end

    it "Has devices" do
      expect(app.devices).not_to be_nil
      expect(app.devices.class).to be Array
    end
  end
end
