require 'liquid'

require 'landable/liquid/tags'
require 'landable/liquid/asset_tags'
require 'landable/liquid/filters'
require 'landable/liquid/proxies'

# Tag generators
Liquid::Template.register_tag('title_tag',    Landable::Liquid::TitleTag)
Liquid::Template.register_tag('meta_tags',    Landable::Liquid::MetaTag)
Liquid::Template.register_tag('head_content', Landable::Liquid::HeadContent)
Liquid::Template.register_tag('head',         Landable::Liquid::Head)
Liquid::Template.register_tag('body',         Landable::Liquid::Body)

%w(img_tag image_tag javascript_include_tag stylesheet_link_tag).each do |tag|
  Liquid::Template.register_tag(tag, Landable::Liquid::AssetTag)
end

# Only called tags so we can use a function-like syntax
Liquid::Template.register_tag('asset_url', Landable::Liquid::AssetAttributeTag)
Liquid::Template.register_tag('asset_description', Landable::Liquid::AssetAttributeTag)
Liquid::Template.register_tag('category_blog_pages', Landable::Liquid::CategoryPages)

# Template references
Liquid::Template.register_tag('template', Landable::Liquid::TemplateTag)

# Helpers
Liquid::Template.register_filter(Landable::Liquid::DefaultFilter)
