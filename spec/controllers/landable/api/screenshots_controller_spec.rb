require 'spec_helper'

module Landable::Api
  describe ScreenshotsController, json: true do
    routes { Landable::Engine.routes }

    before(:each) { Landable::ScreenshotService.stub(:call) }

    describe '#index' do
      context 'for a page' do
        include_examples 'Authenticated API controller', :make_request

        let(:page) { create :page }
        let(:screenshots) { create_list :page_screenshot, 5, screenshotable: page }

        def make_request(page_id = page.id)
          get :index, page_id: page_id
        end

        it "returns all related screenshots" do
          screenshots
          make_request
          response.status.should == 200
          last_json['screenshots'].length.should == 5
        end

        it "returns an empty list if page is not found" do
          make_request random_uuid
          response.status.should == 200
          last_json['screenshots'].length.should == 0
        end
      end

      context 'for a page revision' do
        include_examples 'Authenticated API controller', :make_request

        let(:page_revision) { create :page_revision }
        let(:screenshots) { create_list :page_screenshot, 5, screenshotable: page_revision }

        def make_request(page_revision_id = page_revision.id)
          get :index, page_revision_id: page_revision_id
        end

        it "returns all related screenshots" do
          screenshots
          make_request
          response.status.should == 200
          last_json['screenshots'].length.should == 5
        end

        it "returns an empty list if page is not found" do
          make_request random_uuid
          response.status.should == 200
          last_json['screenshots'].length.should == 0
        end
      end
    end

    describe '#show' do
      include_examples 'Authenticated API controller', :make_request

      let(:screenshot) { create :page_screenshot }

      def make_request(id = screenshot.id)
        get :show, id: id
      end

      it 'returns the selected screenshot' do
        make_request
        response.status.should == 200
        last_json['screenshot']['id'].should == screenshot.id
      end

      it '404s on page not found' do
        make_request random_uuid
        response.status.should == 404
      end
    end

    describe '#create' do
      include_examples 'Authenticated API controller', :make_request

      let(:default_params) { {} }
      let(:default_browser) { create :browser }

      def make_request params = {}
        post :create, default_params.deep_merge(screenshot: params)
      end

      # TODO make this less awful
      before(:each) { Landable::ScreenshotService.stub(:call) }

      context 'for a page' do
        let(:page) { create :page }
        let(:default_params) {
          {
            screenshot: attributes_for(:screenshot).merge(
              screenshotable_id: page.id,
              screenshotable_type: 'page',
              browser_id: default_browser.id
            )
          }
        }

        context 'success' do
          it 'returns 201 Created' do
            make_request
            response.status.should == 201
          end

          it 'returns header Location with the screenshot URL' do
            make_request
            response.headers['Location'].should == screenshot_url(last_json['screenshot']['id'])
          end

          context 'autorun on' do
            it 'should call autorun' do
              Landable.configuration.screenshots.stub(:autorun) { true }
              Landable::ScreenshotService.should_receive(:autorun)
              make_request
            end
          end

          context 'autorun off' do
            it 'should not call autorun' do
              Landable.configuration.screenshots.stub(:autorun) { false }
              Landable::ScreenshotService.should_not_receive(:autorun)
              make_request
            end
          end
        end

        context 'invalid' do
          # it's really unclear what browserstack really requires.
        end
      end

      context 'for a page revision' do
        let(:page_revision) { create :page_revision }
        let(:default_params) {
          {
            screenshot: attributes_for(:screenshot).merge(
              screenshotable_id: page_revision.id,
              screenshotable_type: 'page_revision',
              browser_id: default_browser.id
            )
          }
        }

        context 'success' do
          it 'returns 201 Created' do
            make_request
            response.status.should == 201
          end
        end
      end
    end

    describe '#resubmit' do
      include_examples 'Authenticated API controller', :make_request

      let(:screenshot) { create :page_screenshot }

      def make_request
        post :resubmit, id: screenshot.id
      end

      it 'should call ScreenshotService with the screenshot in question, and update state/image_url' do
        Landable::ScreenshotService.should_receive(:call).with(screenshot)

        make_request

        last_json['screenshot']['id'].should == screenshot.id

        screenshot.reload
        screenshot.state.should == 'unsent'
        screenshot.image_url.should be_nil
      end

      context 'autorun on' do
        it 'should call autorun' do
          Landable.configuration.screenshots.stub(:autorun) { true }
          Landable::ScreenshotService.should_receive(:autorun)
          make_request
        end
      end

      context 'autorun off' do
        it 'should not call autorun' do
          Landable.configuration.screenshots.stub(:autorun) { false }
          Landable::ScreenshotService.should_not_receive(:autorun)
          make_request
        end
      end
    end

    describe '#callback' do
      it 'should pass all params to ScreenshotService.handle_job_callback' do
        Landable::ScreenshotService.should_receive(:handle_job_callback).with('one' => 'two')
        post :callback, 'one' => 'two'
        response.status.should == 200
      end
    end
  end
end
