require 'spec_helper'

module Landable
	describe PageRevision do
		describe '#page_id=' do
			it 'should set page revision attributes matching the page' do
				page = FactoryGirl.create(:page,
					path: '/test/path',
					title: 'title',
					status_code: 200,
					body: 'body',
					redirect_url: '/redirect/here',
					meta_tags: {'key'=>'value'}
				)

				page_revision = PageRevision.new
				page_revision.page_id = page.page_id

				page_revision.page_path.should == page.path
				page_revision.page_title.should == page.title
				page_revision.page_status_code.should == page.status_code
				page_revision.page_body.should == page.body
				page_revision.page_redirect_url.should == page.redirect_url
				page_revision.page_meta_tags.should == page.meta_tags
			end
		end
  	end
end
