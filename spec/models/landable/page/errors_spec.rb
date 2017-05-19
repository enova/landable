require 'spec_helper'

module Landable
  describe Page do
    describe '#error?' do
      describe 'yep' do
        specify { expect(build(:page, status_code: 418)).to be_error }
        specify { expect(build(:page, status_code: 522)).to be_error }
      end

      describe 'nope' do
        specify { expect(build(:page, status_code: 311)).not_to be_error }
        specify { expect(build(:page, status_code: 200)).not_to be_error }
      end
    end

    describe '#error' do
      def error_for(code)
        build(:page, status_code: code).error
      end

      specify { expect(error_for(410)).to be_a Landable::Page::GoneError }
      specify { expect(error_for(555)).to be_a Landable::Error }
      specify { expect(error_for(200)).to be_nil }
      specify { expect(error_for(302)).to be_nil }
    end
  end
end
