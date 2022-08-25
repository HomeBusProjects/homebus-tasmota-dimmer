# coding: utf-8
require 'homebus'

require 'dotenv'
require 'net/http'
require 'json'

class HomebusTasmotaDimmer::App < Homebus::App
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

    @url = @options[:url] || ENV['TASMOTA_DIMMER_URL']
    @power_only = ENV['POWER_ONLY']

    @device = Homebus::Device.new name: "Homebus Tasmota bridge for #{@url}",
                                  manufacturer: 'Homebus',
                                  model: 'Tasmota bridge',
                                  serial_number: @url
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
          answer[:brightness] = tasmota_dimmer
        end
 
        if options[:verbose]
          puts 'homebus publish'
          pp answer
        end

        @device.publish! DDC, answer
      end
    rescue
      puts "FAIL"
    end

    sleep update_delay
  end

  def name
    'HomeBus Tasmota bridge'
  end

  def publishes
    [ DDC ]
  end

  def devices
    [ @device ]
  end
end
