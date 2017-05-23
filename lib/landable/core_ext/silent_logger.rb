module Landable
  module CoreExt
    module SilentLogger
      def add(*args)
        silence { super }
      end
    end
  end
end
