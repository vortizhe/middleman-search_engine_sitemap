xml.instruct!
xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9', "xmlns:xhtml" => "http://www.w3.org/1999/xhtml" do
  resources_for_sitemap.each do |page|
    xml.url do
      default_url = extensions[:search_engine_sitemap].process_url(File.join(app.config.url_root, page.url))
      xml.loc default_url
      xml.link rel: "alternate", hreflang: "x-default", href: default_url
      locales.each do |locale|
        url = localized_resource(page, locale).url
        xml.tag!("xhtml:link",
          rel: "alternate",
          hreflang: locale,
          href: extensions[:search_engine_sitemap].process_url(File.join(app.config.url_root, url))
        )
      end
    end
  end
end
