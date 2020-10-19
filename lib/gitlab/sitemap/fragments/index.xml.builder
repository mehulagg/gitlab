xml.instruct!
xml.sitemapindex :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap_files.each do |path, i|
    xml.sitemap do
      xml.loc path
    end
  end
end
