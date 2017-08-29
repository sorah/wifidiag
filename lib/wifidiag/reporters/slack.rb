require 'uri'
require 'net/http'
require 'net/https'
require 'wifidiag/reporters/base'

module Wifidiag
  module Reporters
    class Slack < Base
      def initialize(webhook_url:)
        @webhook_url = URI.parse(webhook_url)
      end

      def report!(report)
        Net::HTTP.post_form(
          @webhook_url,
          payload: {
            text: "Wi-Fi diagnostic received!" + (report.advanced_data.dig('client', 'q') ? " (#{report.advanced_data['client']['q'].inspect})" : ''),
            mrkdwn: true,
            attachments: [
              {
                fallback: report.to_h.to_json,
                text: "Expand to see raw JSON:\n\n\n\n\n\n```\n#{JSON.pretty_generate(report.to_h)}\n```",
                mrkdwn_in: ['text'],
                fields: [
                  report.client_data&.ssid ? {
                    title: 'SSID',
                    value: report.client_data.ssid,
                    short: true,
                  } : nil,
                  report.client_data&.ap ? {
                    title: 'AP',
                    value: report.client_data.ap&.name || report.client_data.ap&.mac_address || 'n/a',
                    short: true,
                  } : nil,
                  {
                    title: 'IP address',
                    value: report.client_ip,
                    short: true,
                  },
                  report.advanced_data['bandwidth']&.dig('mbps') ? {
                    title: 'Bandwidth',
                    value: "%.4f Mbps" % report.advanced_data['bandwidth']&.dig('mbps'),
                    short: true,
                  } : nil,
                  report.advanced_data['latency'] ? {
                    title: 'Latency',
                    value: "pkt: ok=%d ng=%d rate=%.1f%%\nrtt: min=%.2f avg=%.2f max=%.2f mdev=%.2f time=%.2f ms" \
                      % report.advanced_data['latency']&.values_at(
                        'ok', 'fail', 'rate',
                        'min', 'avg', 'max', 'mdev',
                        'time',
                      ).map{ |_| _ == nil ? -1 : _ },
                    short: false,
                  } : nil,
                  report.advanced_data['client']['ua'] ? {
                    title: 'User agent',
                    value: report.advanced_data['client']['ua'],
                    short: false,
                  } : nil,
                ].compact,
              }
            ]
          }.to_json
        )
      end
    end
  end
end
