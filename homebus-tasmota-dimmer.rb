#!/usr/bin/env ruby

require './options'
require './app'

tasmota_app_options = TasmotaDimmerHomeBusAppOptions.new

tasmota = TasmotaDimmerHomeBusApp.new tasmota_app_options.options
tasmota.run!
