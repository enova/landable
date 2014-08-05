module Landable
  module Traffic
    class Ownership < ActiveRecord::Base
      include Landable::TableName

      belongs_to :cookie
      belongs_to :owner
    end
  end
end
