require 'spec_helper'

describe Landable::Liquid do
  specify 'registered tags' do
    expect(Liquid::Template.tags['title_tag']).to eq Landable::Liquid::TitleTag
    expect(Liquid::Template.tags['meta_tags']).to eq Landable::Liquid::MetaTag
    expect(Liquid::Template.tags['head_content']).to eq Landable::Liquid::HeadContent
    expect(Liquid::Template.tags['head']).to eq Landable::Liquid::Head
    expect(Liquid::Template.tags['body']).to eq Landable::Liquid::Body
    expect(Liquid::Template.tags['img_tag']).to eq Landable::Liquid::AssetTag
    expect(Liquid::Template.tags['image_tag']).to eq Landable::Liquid::AssetTag
    expect(Liquid::Template.tags['javascript_include_tag']).to eq Landable::Liquid::AssetTag
    expect(Liquid::Template.tags['stylesheet_link_tag']).to eq Landable::Liquid::AssetTag
    expect(Liquid::Template.tags['asset_url']).to eq Landable::Liquid::AssetAttributeTag
    expect(Liquid::Template.tags['asset_description']).to eq Landable::Liquid::AssetAttributeTag
    expect(Liquid::Template.tags['template']).to eq Landable::Liquid::TemplateTag
  end

  specify 'registered filters' do
    expect(Liquid::Strainer.class_variable_get(:@@known_filters)).to include(Landable::Liquid::DefaultFilter)
  end
end
