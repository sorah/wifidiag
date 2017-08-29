module Wifidiag
  class ApData
    def initialize(name: , mac_address: nil, **kwargs)
      @name = name
      @mac_address = mac_address
      @additional_data = kwargs
    end

    attr_reader :name, :mac_address
    attr_reader :additional_data


    def to_h
      {
        name: name,
        mac_address: mac_address,
        additional_data: additional_data,
      }
    end
  end
end
