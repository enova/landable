require 'spec_helper'

describe Landable::Liquid do
  specify 'registered tags' do
    Liquid::Template.tags['title_tag'].should eq Landable::Liquid::TitleTag
    Liquid::Template.tags['meta_tags'].should eq Landable::Liquid::MetaTag
    Liquid::Template.tags['head_content'].should eq Landable::Liquid::HeadContent
    Liquid::Template.tags['head'].should eq Landable::Liquid::Head
    Liquid::Template.tags['body'].should eq Landable::Liquid::Body
    Liquid::Template.tags['img_tag'].should eq Landable::Liquid::AssetTag
    Liquid::Template.tags['image_tag'].should eq Landable::Liquid::AssetTag
    Liquid::Template.tags['javascript_include_tag'].should eq Landable::Liquid::AssetTag
    Liquid::Template.tags['stylesheet_link_tag'].should eq Landable::Liquid::AssetTag
    Liquid::Template.tags['asset_url'].should eq Landable::Liquid::AssetAttributeTag
    Liquid::Template.tags['asset_description'].should eq Landable::Liquid::AssetAttributeTag
    Liquid::Template.tags['template'].should eq Landable::Liquid::TemplateTag
  end

  specify 'registered filters' do
    Liquid::Strainer.class_variable_get(:@@known_filters).should include(Landable::Liquid::DefaultFilter)
  end
end
