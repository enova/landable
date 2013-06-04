module Landable
  class NullPageDecorator < Landable::PageDecorator
    def initialize
    end

    def title
      # Obviously, this should instead be configured with Landable in some way,
      # such that you can register the titles you want everywhere. Or, of course,
      # a more reasonable way to bypass Landable entirely yet still use the
      # `landable` helper. Just waiting to tease out what features we need.
      content_tag('title', 'No current page; default title')
    end

    def meta_tags
      ''
    end
  end
end
