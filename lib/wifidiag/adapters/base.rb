module Wifidiag
  module Adapters
    class Base
      def initialize()
      end

      def collect
        raise NotImplementedError
      end
    end
  end
end
