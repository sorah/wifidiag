module Wifidiag
  class Report
    def initialize(client_ip, client_data, advanced_data)
      @client_ip = client_ip
      @client_data = client_data
      @advanced_data = advanced_data
    end

    attr_reader :client_ip, :client_data, :advanced_data

    def to_h
      {
        client_ip: client_ip,
        client_data: client_data.to_h,
        advanced_data: advanced_data.to_h,
      }
    end
  end
end
