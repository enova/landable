require 'spec_helper'

module Landable::Api
  describe AuditsController, json: true do
    routes { Landable::Engine.routes }

    let(:page)     { create :page }
    let(:template) { create :template }


    describe '#index' do
      context 'all' do
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

      context 'tempalte audits' do
        include_examples 'Authenticated API controller', :make_request

        let(:audits) { create_list :audit, 3, auditable_id: template.id, auditable_type: 'Landable::Template', approver: 'ME!!!' }

        before(:each) { audits }

        def make_request(params = {})
          get :index, auditable_id: template.id
        end

        it 'renders audits as json' do
          make_request
          last_json['audits'].collect { |p| p['id'] }.sort.should == Landable::Audit.all.map(&:id).sort
        end
      end

      context 'page audits' do
        include_examples 'Authenticated API controller', :make_request

        let(:audits) { create_list :audit, 3, auditable_id: page.id, auditable_type: 'Landable::Page', approver: 'ME!!!' }

        before(:each) { audits }

        def make_request(params = {})
          get :index, auditable_id: page.id
        end

        it 'renders audits as json' do
          make_request
          last_json['audits'].collect { |p| p['id'] }.sort.should == Landable::Audit.all.map(&:id).sort
        end
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

    describe '#create' do
      context 'template audit' do
        include_examples 'Authenticated API controller', :make_request

        let(:default_params) do
          { audit: attributes_for(:audit).merge(auditable_id: template.id,
                                                auditable_type: 'Landable::Template',
                                                approver: 'Marley') }
        end

        let(:audit) do
          Landable::Audit.where(auditable_id: default_params[:audit][:auditable_id]).first
        end

        def make_request(params = {})
          post :create, default_params.deep_merge(audit: params, template_id: template.id)
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

      context 'page audit' do
        include_examples 'Authenticated API controller', :make_request

        let(:default_params) do
          { audit: attributes_for(:audit).merge(auditable_id: page.id,
                                                auditable_type: 'Landable::Page',
                                                approver: 'Marley') }
        end

        let(:audit) do
          Landable::Audit.where(auditable_id: default_params[:audit][:auditable_id]).first
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
    end
  end
end
