require 'bundler/setup'
require 'wifidiag'

config =   Wifidiag::Config.new(
  adapter: Wifidiag::Adapters::CiscoWlc.new(
    host: ENV.fetch('WLC_HOST'),
    community: ENV.fetch('WLC_COMMUNITY'),
  ),
  reporters: [
    ENV['WIFIDIAG_SLACK_WEBHOOK_URL'] ? Wifidiag::Reporters::Slack.new(
      webhook_url: ENV['WIFIDIAG_SLACK_WEBHOOK_URL'],
    ) : nil,
  ].compact,
  dummy_ip: ENV['WIFIDIAG_DUMMY_IP'],
  edge_url: ENV['WIFIDIAG_EDGE_URL'],
)

config.collector.start_periodic_update(60)

run Wifidiag.app(config)
