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
          controller.instance_variable_set :@author, asset.author
          allow(@author).to receive(:can_read?).and_return('true')
          allow(@author).to receive(:can_edit?).and_return('true')
          allow(@author).to receive(:can_publish?).and_return('true')

          make_request
          asset.reload
          asset.description.should eq 'Updated'
        end
      end
    end
  end
end
