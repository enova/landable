require 'spec_helper'

module Landable
  describe Theme do
    it { is_expected.to have_valid(:thumbnail_url).when(nil) }
    it { is_expected.to be_a HasAssets }

    describe '#most_used_theme' do
      it 'returns the most used theme' do
        t = create :theme
        t2 = create :theme
        create :theme
        create :page, theme: t
        create :page, theme: t
        create :page, theme: t2
        create :page, theme: t

        expect(Theme.most_used_on_pages).to eq t
      end

      it 'return nil when there are no themes' do
        Theme.destroy_all # Remove all themes!
        expect(Theme.most_used_on_pages).to be_nil
      end
    end
  end
end
