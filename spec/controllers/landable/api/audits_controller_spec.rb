require 'spec_helper'

module Landable::Api
  describe AuditsController, json: true do
    routes { Landable::Engine.routes }

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:audits) { create_list :audit, 3 }

      before(:each) { audits }

      def make_request(params = {})
        get :index
      end

      it 'renders audits as json' do
        make_request
        last_json['audits'].collect { |p| p['id'] }.sort.should == Landable::Audit.all.map(&:id).sort
      end
    end

    describe '#show' do
      include_examples 'Authenticated API controller', :make_request
      let(:audit) { create(:audit) }

      def make_request(id = audit.id)
        get :show, id: id
      end

      it 'renders the page as JSON' do
        make_request
        last_json['audit']['flags'].should == audit.flags
      end

      context 'no such page' do
        it 'returns 404' do
          make_request random_uuid
          response.status.should == 404
        end
      end
    end
  end
end
