require 'spec_helper'

module Landable
  describe Page do
    describe '#error?' do
      describe 'yep' do
        specify { build(:page, status_code: 418).should be_error }
        specify { build(:page, status_code: 522).should be_error }
      end

      describe 'nope' do
        specify { build(:page, status_code: 311).should_not be_error }
        specify { build(:page, status_code: 200).should_not be_error }
      end
    end

    describe '#error' do
      def error_for(code)
        build(:page, status_code: code).error
      end

      specify { error_for(410).should be_a Landable::Page::GoneError }
      specify { error_for(555).should be_a Landable::Error }
      specify { error_for(200).should be_nil }
      specify { error_for(302).should be_nil }
    end
  end
end
