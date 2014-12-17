require 'spec_helper'

module Landable
  describe Theme do
    it { should have_valid(:thumbnail_url).when(nil) }
    it { should be_a HasAssets }

    describe '#most_used_theme' do
      it 'returns the most used theme' do
        t = create :theme
        t2 = create :theme
        t3 = create :theme
        create :page, theme: t
        create :page, theme: t
        create :page, theme: t2
        create :page, theme: t

        Theme.most_used_on_pages.should == t
      end
    end
  end
end
