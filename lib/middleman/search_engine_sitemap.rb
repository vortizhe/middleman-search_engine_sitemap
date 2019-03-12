require "middleman-core"
require "middleman/search_engine_sitemap/version"
require "builder"

module Middleman
  module SearchEngineSitemap
    TEMPLATES_DIR = File.expand_path(File.join('..', 'search_engine_sitemap', 'templates'), __FILE__)

    class Extension < Middleman::Extension
      option :sitemap_xml_path, 'sitemap.xml', 'Path to search engine sitemap'
      option :exclude_attr, 'hide_from_sitemap'
      option :process_url, nil, 'Proc for processing a URL'
      option :exclude_if, ->(resource) { false }

      def manipulate_resource_list(resources)
        resources << sitemap_resource
      end

      def resource_in_sitemap?(resource)
        is_page?(resource) && not_excluded?(resource)
      end

      def process_url(url)
        options.process_url ? options.process_url.call(url) : url
      end

      helpers do
        def resources_for_sitemap
          sitemap.resources
            .select {|r| extensions[:search_engine_sitemap].resource_in_sitemap?(r) }
            .select {|r| r.metadata[:options][:locale] == I18n.default_locale }
        end

        def localized_resource resource, locale
          original_target = resource.target.sub(/\.[a-z]{2}\.html$/, ".html")
          resource = sitemap.resources
            .select { |r| r.try(:target) }
            .select { |r| r.target.match(original_target) }
            .find { |r| r.metadata[:options][:locale] == locale}

          raise "Can't find resource in sitemap for #{target} with #{original_target}" unless resource

          resource
        end
      end

      private

      def is_page?(resource)
        resource.path.end_with?(page_ext)
      end

      def not_excluded?(resource)
        !resource.ignored? && !resource.data[options.exclude_attr] && !options.exclude_if.call(resource)
      end

      def page_ext
        File.extname(app.config.index_file)
      end

      def sitemap_resource
        source_file = template('sitemap.xml.builder')

        Middleman::Sitemap::Resource.new(app.sitemap, sitemap_xml_path, source_file).tap do |resource|
          resource.add_metadata(options: { layout: false })
        end
      end

      def template(path)
        full_path = File.join(TEMPLATES_DIR, path)
        raise "Template #{full_path} not found" if !File.exist?(full_path)
        full_path
      end

      def sitemap_xml_path
        options.sitemap_xml_path
      end
    end
  end
end

::Middleman::Extensions.register(:search_engine_sitemap, ::Middleman::SearchEngineSitemap::Extension)
