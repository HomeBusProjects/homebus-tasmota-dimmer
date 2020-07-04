# coding: utf-8
require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'dotenv'
require 'net/http'
require 'json'

class TasmotaDimmerHomeBusApp < HomeBusApp
  DDC = 'org.homebus.experimental.switch'

  def initialize(options)
    @options = options
    @old_brightness = nil
    @old_power = nil
    super
  end

  def update_delay
    60
  end

  def setup!
    Dotenv.load('.env')

    @url = ENV['TASMOTA_DIMMER_URL']
    @power_only = ENV['POWER_ONLY']
  end

  def _get_dimmer
    if @power_only
      return nil
    end

    uri = URI(@url+ '/cm?cmnd=Dimmer')
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

    tasmota[:Dimmer]
  end

  def _get_power
    uri = URI(@url+ '/cm?cmnd=Power')
    results = Net::HTTP.get(uri)

    if options[:verbose]
      puts 'power response (raw)'
      pp results
    end

    tasmota = JSON.parse results, symbolize_names: true

    if options[:verbose]
      puts 'power response (JSON):'
      pp tasmota
    end

    tasmota[:POWER]
  end

  def work!
    tasmota_dimmer = nil

    begin
      unless @power_only
        tasmota_dimmer = _get_dimmer
      end

      tasmota_power = _get_power

      if @old_brightness != tasmota_dimmer || @old_power != tasmota_power
        @old_brightness = tasmota_dimmer
        @old_power = tasmota_power

        answer = {
          state: tasmota_power == 'ON' ? 'on' : 'off'
        }

        unless @power_only
          answer[][:brightness] = tasmota_dimmer
        end
 
        if options[:verbose]
          puts 'homebus publish'
          pp answer
        end

        publish! DDC, answer
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
      { friendly_name: 'Tasmota Dimmer Switch',
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
