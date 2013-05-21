module Landable
  class Path < ActiveRecord::Base
    self.table_name = 'landable.paths'

    validates_presence_of :path, :status_code
    belongs_to :page

    def directory_after(prefix)
      remainder = path.gsub(/^#{prefix}\/?/, '')
      segments  = remainder.split('/', 2)
      if segments.length == 1
        nil
      else
        segments.first
      end
    end
  end
end
