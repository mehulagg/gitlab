xml.instruct!
xml.sitemapindex :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap_files.each_with_index do |fragment, i|
    xml.sitemap do
      xml.loc file_url("sitemaps/sitemap-#{i + 1}.xml")
    end
  end
end
