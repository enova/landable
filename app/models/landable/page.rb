module Landable
  class Page < ActiveRecord::Base
    self.table_name = 'landable.pages'

    validates_presence_of :theme, :title, :body
    # validate :theme_exists

    private

    def theme_exists
      return if theme.blank?
      return if Landable.find_theme(theme).present?
      errors.add(:theme, "Undefined theme #{theme}")
    end
  end
end
