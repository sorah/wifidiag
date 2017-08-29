require 'wlc_snmp'

require 'wifidiag/adapters/base'

require 'wifidiag/ap_data'
require 'wifidiag/client_data'

module Wifidiag
  module Adapters
    class CiscoWlc
      def initialize(host:, port: 161, community:)
        @host = host
        @port = port
        @community = community
      end

      def collect
        aps = {}
        wlc.clients.map do |client|
          if client.ap
            ap = aps.fetch(client.ap_mac) do
              aps[client.ap_mac] = ApData.new(
                name: client.ap.name,
                mac_address: client.ap.mac_address,
                location: client.ap.location,
                model: client.ap.model,
              )
            end
          end
          ClientData.new(
            mac_address: client.mac_address,
            ip_address: client.ip_address,
            ap: ap,
            wlan_profile: client.wlan_profile,
            protocol: client.protocol,
            ap_mac: client.ap_mac,
            uptime: client.uptime,
            current_rate: client.current_rate,
            supported_data_rates: client.supported_data_rates,
            user: client.user,
            ssid: client.ssid,
          )
        end
      end

      def wlc
        @snmp ||= WlcSnmp::Client.new(host: @host, port: @port, community: @community)
      end
    end
  end
end
