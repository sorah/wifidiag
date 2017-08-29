module Wifidiag
  module Reporters
    class Base
      def report!(report)
        raise NotImplementedError
      end
    end
  end
end
