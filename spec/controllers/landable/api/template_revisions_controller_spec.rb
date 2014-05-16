require 'spec_helper'

module Landable::Api
  describe TemplateRevisionsController, json: true do
    routes { Landable::Engine.routes }

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:template) { create :template }

      def make_request(template_id = template.id)
        get :index, template_id: template_id
      end

      it "returns all of a template's revisions" do
        template.publish! author: current_author
        make_request
        response.status.should == 200
        last_json['template_revisions'].length.should == 1
      end

      it "404s on page not found" do
        make_request random_uuid
        response.status.should == 404
      end
    end
  end
end
