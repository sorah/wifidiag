require 'thread'

module Wifidiag
  # Collect client and AP information from +an adapter+
  class Collector
    def initialize(adapter)
      @lock = Mutex.new

      @adapter = adapter

      @clients = nil
      @clients_by_ip_address = nil
      @clients_by_mac_address = nil
      @last_update = nil
    end

    attr_reader :adapter, :last_update

    def start_periodic_update(interval) # XXX:
      self.collect

      Thread.new do
        loop do
          begin
            self.collect
            sleep interval
          rescue Exception => e
            $stderr.puts "Periodic update error: #{e.inspect}"
            e.backtrace.each do |x|
              $stderr.puts "\t#{x}"
            end
            sleep interval
          end
        end
      end
    end

    def collect
      @lock.synchronize do
        clients = adapter.collect()
        clients_by_ip_address = clients.map { |_| [_.ip_address, _] }.to_h
        clients_by_mac_address = clients.map { |_| [_.mac_address, _] }.to_h
        @clients = clients
        @clients_by_ip_address = clients_by_ip_address
        @clients_by_mac_address = clients_by_mac_address
        @last_update = Time.now
      end
    end

    def client_data_for_ip_address(address)
      @clients_by_ip_address[address]
    end

    def client_data_for_mac_address(address)
      @clients_by_mac_address[address]
    end
  end
end
