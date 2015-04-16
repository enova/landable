module Landable
  module Traffic
    class Attribution < ActiveRecord::Base
      include Landable::TableName

      KEYS = %w(ad_type ad_group bid_match_type campaign content creative device_type experiment keyword match_type medium network placement position search_term source target)

      self.record_timestamps = false

      KEYS.each do |key|
        lookup_for key.to_sym, class_name: "Landable::Traffic::#{key.classify}".constantize
      end

      has_many :visits

      class << self
        def transform(parameters)
          hash = parameters.slice(*KEYS)

          filter = {}

          hash.each do |k, v|
            filter[k.foreign_key] = "Landable::Traffic::#{k.classify}".constantize[v]
          end

          filter
        end

        def lookup(parameters)
          where(transform(parameters)).first_or_create
        end

        def digest(parameters)
          Digest::SHA2.base64digest transform(parameters).values.join
        end
      end
    end
  end
end
