require 'spec_helper'

describe Landable::Liquid do

  specify 'registered tags' do
    Liquid::Template.tags['title_tag'].should              == Landable::Liquid::TitleTag
    Liquid::Template.tags['meta_tags'].should              == Landable::Liquid::MetaTags
    Liquid::Template.tags['head_conent'].should            == Landable::Liquid::HeadContent
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
