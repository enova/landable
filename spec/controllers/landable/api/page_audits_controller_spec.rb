require 'spec_helper'

module Landable::Api
  describe PageAuditsController, json: true do
    routes { Landable::Engine.routes }

    let(:page) { create :page }

    describe '#create' do
      include_examples 'Authenticated API controller', :make_request

      let(:default_params) do
        { page_audit: attributes_for(:audit).merge(auditable_id: page.id, auditable_type: 'Landable::Page') }
      end

      let(:audit) do
        Landable::Audit.where(auditable_id: default_params[:page_audit][:auditable_id]).first
      end

      def make_request(params = {})
        post :create, default_params.deep_merge(page_audit: params, page_id: page.id)
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
          Landable::Audit.create!(auditable_id: page.id, auditable_type: 'Landable::Page', notes: 'whatever')
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
