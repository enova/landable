require 'ipaddr'

module Landable
  module CoreExt
    module IPAddr
      def ==(other)
        case other
        when true, false then false
        else super
        end
      end
    end
  end
end

class IPAddr
  include Landable::CoreExt::IPAddr
end
