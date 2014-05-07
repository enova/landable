Then 'the element "$css" should exist' do |css|
  doc = Nokogiri::HTML(last_response.body)
  doc.at(css).should be_present
end

Then 'the element "$css" should have inner text "$text"' do |css, text|
  doc = Nokogiri::HTML(last_response.body)
  doc.at(css).text.should == text
end
