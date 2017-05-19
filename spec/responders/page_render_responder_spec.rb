require 'spec_helper'

describe Landable::PageRenderResponder do
  let(:page) { build :page }
  let(:responder) { Landable::PageRenderResponder.new double(request: double, formats: []), [page] }

  describe '#to_html' do
    context 'okay' do
      it 'should render a 200' do
        content = double
        content_type = double
        expect(Landable::RenderService).to receive(:call) { content }
        expect(page).to receive(:content_type) { content_type }

        expect(responder).to receive(:render).with(text: content, content_type: content_type, layout: false)

        responder.to_html
      end
    end

    context 'redirect' do
      let(:page) { build :page, :redirect }

      it 'should render a redirect' do
        expect(responder).to receive(:redirect_to).with(page.redirect_url, status: page.status_code)
        expect(responder).not_to receive(:render)

        responder.to_html
      end
    end

    context 'missing' do
      let(:page) { build :page, :gone }

      it 'should render a 410' do
        expect { responder.to_html }.to raise_error(Landable::Page::GoneError)
        expect(responder).not_to receive(:render)
      end
    end
  end
end
