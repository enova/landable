module Landable
  class PageGoneError < StandardError
    def initialize(msg = 'Page has a status code of 410. Rescue Landable::PageGoneError to handle as you see fit')
      super(msg)
    end
  end
end
