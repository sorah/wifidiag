require 'wifidiag/collector'

module Wifidiag
  class Config
    def initialize(hash)
      @hash = hash
    end

    def [](k)
      @hash[k]
    end

    def fetch(*args)
      @hash.fetch(*args)
    end

    def dig(*args)
      @hash.dig(*args)
    end

    def adapter
      @hash.fetch(:adapter)
    end

    def collector
      @collector ||= Collector.new(adapter)
    end
  end
end
