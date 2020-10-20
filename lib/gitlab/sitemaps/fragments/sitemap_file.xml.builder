xml.instruct!
xml.urlset :xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  urls.flatten.compact.each do |url|
    xml.url do
      xml.loc url
      xml.lastmod lastmod
    end
  end
end
