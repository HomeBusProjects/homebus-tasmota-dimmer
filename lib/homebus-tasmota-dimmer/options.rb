require 'homebus/options'

class HomebusTasmotaDimmer::Options < Homebus::Options
  def app_options(op)
    tasmota_url_help = 'URL for the Tasmota switch'

    op.separator 'Tasmota Dimmer options:'
    op.on('-u', '--url ', tasmota_url_help) { |value| options[:url] = value }
  end

  def banner
    'HomeBus Tasmota Dimmer'
  end

  def version
    HomebusTasmotaDimmer::VERSION
  end

  def name
    'homebus-tasmota-dimmer'
  end
end
