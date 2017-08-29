module Wifidiag
  class ClientData
    def initialize(ip_address: , mac_address: nil, ssid: nil, ap: nil, **kwargs)
      @ip_address = ip_address
      @mac_address = mac_address
      @ssid = ssid
      @additional_data = kwargs
      @ap = ap
    end

    attr_reader :ip_address, :mac_address, :ssid, :ap
    attr_reader :additional_data

    def to_h
      {
        ip_address: ip_address,
        mac_address: mac_address,
        ssid: ssid,
        ap: ap.to_h,
        additional_data: additional_data,
      }
    end
  end
end
