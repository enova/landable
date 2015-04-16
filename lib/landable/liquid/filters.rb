module Landable
  module Liquid
    module DefaultFilter
      def default(input, default_output = nil)
        input.presence ? input : default_output
      end
    end
  end
end
