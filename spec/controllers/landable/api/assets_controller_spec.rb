require 'spec_helper'

module Landable
  module Api
    describe AssetsController, json: true do
      routes { Landable::Engine.routes }

      describe '#update' do
        include_examples 'Authenticated API controller', :make_request

        let(:asset) { create :asset, description: 'Not updated' }

        def make_request
          put :update, id: asset.id, asset: { description: 'Updated' }
        end

        it 'updates the asset description' do
          make_request
          asset.reload
          expect(asset.description).to eq 'Updated'
        end
      end
    end
  end
end
