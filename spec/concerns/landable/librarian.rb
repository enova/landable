require 'spec_helper'

module Landable
  # descriptions
  describe Librarian do
    # setup
    before do
      @page = create(:page)
    end

    # tests
    it "should soft delete a content managed Item" do
      # setup
      current_page = Page.find(@page.id)
      
      # actions
      current_page.deactivate

      # expectations
      expect(current_page).to be_a Page
      expect(current_page.deleted_at).to_not be_blank
      
      # end
    end

    it "should restore a content managed Item" do
      # setup
      Page.find(@page.id).deactivate
      restored_page = Page.find(@page.id)

      # actions
      restored_page.reactivate

      # expectations
      expect(restored_page).to be_a Page
      expect(restored_page.deleted_at).to be_blank

      # end
    end

    # end
  end

  # end
end
