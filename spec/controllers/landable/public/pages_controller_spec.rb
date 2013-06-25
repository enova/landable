require 'spec_helper'

module Landable::Public
  describe PagesController do
    routes { Landable::Engine.routes }

    describe '#show' do
      describe '200 OK' do
        let(:path) { '/foo.html' }
        let(:page) { create(:page, path: path) }

        it 'works' do
          expect(page).to be_kind_of(Landable::Page)
        end

        describe 'valid URLs' do
          context 'allows a' do
            let(:path) { '/a.html' }

            it 'works' do
              expect(page).to be_kind_of(Landable::Page)
            end
          end
        end
      end
    end
  end
end
