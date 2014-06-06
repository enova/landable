require 'spec_helper'

module Landable::Api
  describe TemplateAuditsController, json: true do
    routes { Landable::Engine.routes }

    let(:template) { create :template }

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:audits) do
        3.times do
          Landable::Audit.create!(auditable_id: template.id, auditable_type: 'Landable::Template', approver: 'ME!!!')
        end
      end

      before(:each) { audits }

      def make_request(params = {})
        get :index, auditable_id: template.id
      end

      it 'renders audits as json' do
        make_request
        last_json['template_audits'].collect { |p| p['id'] }.sort.should == Landable::Audit.all.map(&:id).sort
      end
    end
  end
end
