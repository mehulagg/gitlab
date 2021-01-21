# frozen_string_literal: true

xml_builder.instruct!
xml_builder.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  urls.flatten.compact.each do |url|
    xml_builder.url do
      xml_builder.loc url
      xml_builder.lastmod lastmod
    end
  end
end
