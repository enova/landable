require 'spec_helper'

describe Landable::Liquid do

  specify 'registered tags' do
    Liquid::Template.tags['title_tag'].should              == Landable::Liquid::TitleTag
    Liquid::Template.tags['meta_tags'].should              == Landable::Liquid::MetaTag
    Liquid::Template.tags['head_content'].should           == Landable::Liquid::HeadContent
    Liquid::Template.tags['head'].should                   == Landable::Liquid::Head
    Liquid::Template.tags['body'].should                   == Landable::Liquid::Body
    Liquid::Template.tags['img_tag'].should                == Landable::Liquid::AssetTag
    Liquid::Template.tags['image_tag'].should              == Landable::Liquid::AssetTag
    Liquid::Template.tags['javascript_include_tag'].should == Landable::Liquid::AssetTag
    Liquid::Template.tags['stylesheet_link_tag'].should    == Landable::Liquid::AssetTag
    Liquid::Template.tags['asset_url'].should              == Landable::Liquid::AssetAttributeTag
    Liquid::Template.tags['asset_description'].should      == Landable::Liquid::AssetAttributeTag
    Liquid::Template.tags['template'].should               == Landable::Liquid::TemplateTag
  end

  specify 'registered filters' do
    Liquid::Strainer.class_variable_get(:@@known_filters).should include(Landable::Liquid::DefaultFilter)
  end

end
