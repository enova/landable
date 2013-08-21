require 'spec_helper'

module Landable
  describe HeadTag do
    it { should belong_to(:page) }

    describe '#content' do
      it 'is required' do
        head_tag = HeadTag.new content: nil
        head_tag.should_not have_valid(:content).when(nil, '')
        head_tag.should have_valid(:content).when('<meta>', '<link>')
      end
    end
  end
end
