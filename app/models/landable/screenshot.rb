module Landable
  class Screenshot < ActiveRecord::Base
    self.table_name = 'landable.screenshots'

    belongs_to :browser, class_name: 'Landable::Browser'
    belongs_to :screenshotable, polymorphic: true, inverse_of: :screenshots

    validates_presence_of :screenshotable
    validates_presence_of :browser

    delegate :browserstack_attributes, to: :browser

    before_create :set_state

    # ember will be posting this as 'page' or 'page_revision'
    def screenshotable_type= type
      type = "Landable::#{type.camelize}" if type.underscore == type
      self[:screenshotable_type] = type
    end

    def url
      screenshotable.try(:preview_url)
    end

    protected

    def set_state
      unless browserstack_id
        self[:state] ||= 'unsent'
      end
    end

  end
end
