# coding: utf-8
require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'dotenv'
require 'net/http'
require 'json'

class TasmotaDimmerHomeBusApp < HomeBusApp
  def initialize(options)
    @options = options
    @old_brightness = nil
    super
  end

  def update_delay
    60
  end

  def setup!
    Dotenv.load('.env')

    @url = ENV['TASMOTA_DIMMER_URL']
  end

  def work!
    uri = URI(@url+ '/cm?cmnd=Dimmer')

    begin
      results = Net::HTTP.get(uri)

      if options[:verbose]
        puts 'dimmer response (raw)'
        pp results
      end

      tasmota = JSON.parse results, symbolize_names: true

      if options[:verbose]
        puts 'dimmer response (JSON):'
        pp tasmota
      end

      if @old_brightness != tasmota[:Dimmer]
        @old_brightness = tasmota[:Dimmer]

        answer =  {
          id: @uuid,
          timestamp: Time.now.to_i,
          'org.homebus.light-switch': {
                                        state: tasmota[:Dimmer] > 0 ? 'on' : 'off',
                                        brightness: tasmota[:Dimmer]
                                      }
        }
 
        if options[:verbose]
          puts 'homebus publish'
          pp answer
        end

        @mqtt.publish 'homebus/' + @uuid,
                      JSON.generate(answer),
                      true
      end
    rescue
      puts "FAIL"
    end

    sleep update_delay
  end

  def manufacturer
    'HomeBus'
  end

  def model
    'Tasmota Dimmer Adapter'
  end

  def friendly_name
    'Tasmota Dimmer Adapter'
  end

  def friendly_location
    ''
  end

  def serial_number
    @url
  end

  def pin
    ''
  end

  def devices
    [
      { friendly_name: 'Air Quality Index',
        friendly_location: 'Portland, OR',
        update_frequency: update_delay,
        index: 0,
        accuracy: 0,
        precision: 0,
        wo_topics: [ 'org.homebus.light-switch' ],
        ro_topics: [],
        rw_topics: []
      }
    ]
  end
end
