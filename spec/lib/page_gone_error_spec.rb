require 'spec_helper'

module Landable
  describe PageGoneError do
    describe 'raise' do
      it 'returns a message' do
        msg = 'Page has a status code of 410. Rescue Landable::PageGoneError to handle as you see fit'
        expect { raise Landable::PageGoneError }.to raise_error(msg)
      end
    end
  end
end
