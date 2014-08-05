module Landable
  module Traffic
    class Experiment < ActiveRecord::Base
      include Landable::TableName

      lookup_by :experiment, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
