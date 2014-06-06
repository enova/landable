require 'spec_helper'

module Landable::Api
  describe PageAuditsController, json: true do
    routes { Landable::Engine.routes }

    let(:page) { create :page }

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:audits) do
        3.times do
          Landable::Audit.create!(auditable_id: page.id, auditable_type: 'Landable::Page', notes: 'whatever', approver: 'ME!!!')
        end
      end

      before(:each) { audits }

      def make_request(params = {})
        get :index, auditable_id: page.id
      end

      it 'renders audits as json' do
        make_request
        last_json['page_audits'].collect { |p| p['id'] }.sort.should == Landable::Audit.all.map(&:id).sort
      end
    end
  end
end
