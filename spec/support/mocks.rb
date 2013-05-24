module Landable
  module Mock
    class LdapClient
      attr_accessor :entry_generator, :will_authenticate

      def initialize
        @will_authenticate = false
      end

      def search(*args)
        entry_generator.call(*args)
      end

      def auth(dn, pass)
        if pass == 'fail'
          @will_authenticate = false
        else
          @will_authenticate = true
        end
      end

      def bind
        @will_authenticate
      end

      protected

      def entry_generator
        @entry_generator ||= proc do
          [OpenStruct.new(uid: ['trogdor'], mail: ['trogdor@example.com'], givenname: ['Team'], sn: ['Trogdor'])]
        end
      end

    end
  end
end
