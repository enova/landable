require 'spec_helper'

describe Landable::PageRenderResponder do

  let(:page) { build :page }
  let(:responder) { Landable::PageRenderResponder.new double(request: double, formats: []), [page] }

  describe '#to_html' do
    context 'okay' do
      it 'should render a 200' do
        content = double
        content_type = double
        Landable::RenderService.should_receive(:call) { content }
        page.should_receive(:content_type) { content_type }

        responder.should_receive(:render).with(text: content, content_type: content_type, layout: false)

        responder.to_html
      end
    end

    context 'redirect' do
      let(:page) { build :page, :redirect }

      it 'should render a redirect' do
        responder.should_receive(:redirect_to).with(page.redirect_url, status: page.status_code)
        responder.should_not_receive(:render)

        responder.to_html
      end
    end

    context 'missing' do
      let(:page) { build :page, :not_found }

      it 'should render a 410' do
        responder.should_receive(:head).with(410)
        responder.should_not_receive(:render)

        responder.to_html
      end
    end
  end

end
