require 'spec_helper'

module Landable::Api
  describe TemplateAuditsController, json: true do
    routes { Landable::Engine.routes }

    let(:template) { create :template }

    describe '#create' do
      include_examples 'Authenticated API controller', :make_request

      let(:default_params) do
        { template_audit: attributes_for(:audit).merge(auditable_id: template.id, auditable_type: 'Landable::Template') }
      end

      let(:audit) do
        Landable::Audit.where(auditable_id: default_params[:template_audit][:auditable_id]).first
      end

      def make_request(params = {})
        post :create, default_params.deep_merge(template_audit: params, template_id: template.id)
      end

      context 'success' do
        it 'returns 201 Created' do
          make_request
          response.status.should == 201
        end

        it 'returns header Location with the audit URL' do
          make_request
          response.headers['Location'].should == audit_url(audit)
        end

        it 'renders the audit as JSON' do
          make_request
          last_json['audit']['flags'].should == audit.flags 
        end
      end
    end

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:audits) do
        3.times do
          Landable::Audit.create!(auditable_id: template.id, auditable_type: 'Landable::Template', notes: 'whatever')
        end
      end

      before(:each) { audits }

      def make_request(params = {})
        get :index, template_id: template.id
      end

      it 'renders audits as json' do
        make_request
        last_json['template_audits'].collect { |p| p['id'] }.sort.should == Landable::Audit.all.map(&:id).sort
      end
    end
  end
end
