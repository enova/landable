class FixStatusCodes < ActiveRecord::Migration
  def up
    Landable::Page.where(status_code: 404).each do |page| 
      page.status_code = 410
      page.save!
    end
  end
end
