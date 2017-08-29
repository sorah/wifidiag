require 'sinatra/base'
require 'json'

require 'wifidiag/report'

module Wifidiag
  def self.app(*args)
    App.rack(*args)
  end

  class App < Sinatra::Base
    class Boom < StandardError; end

    CONTEXT_RACK_ENV_NAME = 'wifidiag.ctx'

    set :root, File.expand_path(File.join(__dir__, '..', '..', 'app'))

    def self.initialize_context(config)
      {
        config: config,
        revision: self.revision(),
      }
    end

    def self.revision
      path = File.join(__dir__, '..', '..', 'REVISION')
      if File.exist?(path)
        File.read(path).chomp
      else
        nil
      end
    end

    def self.rack(config={})
      klass = App

      context = initialize_context(config)
      app = lambda { |env|
        env[CONTEXT_RACK_ENV_NAME] = context
        klass.call(env)
      }
    end

    helpers do
      def context
        request.env[CONTEXT_RACK_ENV_NAME]
      end

      def conf
        context[:config]
      end

      def collector
        conf.collector
      end

      def revision
        context[:revision]
      end

      TRUSTED_IPS = /\A127\.0\.0\.1\Z|\A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|\A::1\Z|\Afd[0-9a-f]{2}:.+|\Alocalhost\Z|\Aunix\Z|\Aunix:/i
      def client_ip
        return conf[:dummy_ip] if conf[:dummy_ip]
        @client_ip ||= begin
          remote_addrs = request.get_header('REMOTE_ADDR')&.split(/,\s*/)
          filtered_remote_addrs = remote_addrs.grep_v(TRUSTED_IPS)

          if filtered_remote_addrs.empty? && request.get_header('HTTP_X_FORWARDED_FOR')
            forwarded_ips = request.get_header('HTTP_X_FORWARDED_FOR')&.split(/,\s*/)
            filtered_forwarded_ips = forwarded_ips.grep_v(TRUSTED_IPS)

            filtered_forwarded_ips.empty? ? forwarded_ips.first : remote_addrs.first
          else
            filtered_remote_addrs.first || remote_addrs.first
          end
        end
      end

      def data
        begin
          @data = JSON.parse(request.body.tap(&:rewind).read)
        rescue JSON::ParserError
          halt 400, '{"error": "invalid_payload"}'
        end
      end

    end

    configure do
      enable :logging
    end

    get '/' do
      @client = conf.collector.client_data_for_ip_address(client_ip)
      erb :index
    end

    get '/api/self' do
      content_type :json
      data = conf.collector.client_data_for_ip_address(client_ip)
      if data
        data.to_h.to_json
      else
        halt 404, {error: :not_found, ip: client_ip}.to_json
      end
    end

    post '/api/report' do
      content_type :json
      report = Report.new(
        client_ip,
        conf.collector.client_data_for_ip_address(client_ip),
        data['data'] || {},
      )

      conf[:reporters].each do |x|
        x.report! report
      end

      '{"status": "ok"}'
    end
  end
end
