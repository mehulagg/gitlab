xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9", 'xmlns:rs' => 'http://www.openarchives.org/rs/terms/' do
  xml.tag!('rs:md', { :capability => 'resourcelist', :at => Time.now.iso8601 })

  urls.flatten.compact.each do |url|
    xml.url do
      xml.loc url
    end
  end
end
