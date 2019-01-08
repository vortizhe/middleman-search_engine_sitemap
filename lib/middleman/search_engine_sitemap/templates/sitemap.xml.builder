xml.instruct!
xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  resources_for_sitemap.each do |page|
    xml.url do
      xml.loc extensions[:search_engine_sitemap].process_url(File.join(app.config.url_root, page.url))
    end
  end
end
