# frozen_string_literal: true

module Packages
  module Nuget
    class MetadataExtractionService
      include Gitlab::Utils::StrongMemoize

      ExtractionError = Class.new(StandardError)

      XPATHS = {
        package_name: '//xmlns:package/xmlns:metadata/xmlns:id',
        package_version: '//xmlns:package/xmlns:metadata/xmlns:version'
      }.freeze

      XPATH_DEPENDENCIES = '//xmlns:package/xmlns:metadata/xmlns:dependencies/xmlns:dependency'
      XPATH_DEPENDENCY_GROUPS = '//xmlns:package/xmlns:metadata/xmlns:dependencies/xmlns:group'

      MAX_FILE_SIZE = 4.megabytes.freeze

      def initialize(package_file_id)
        @package_file_id = package_file_id
      end

      def execute
        raise ExtractionError.new('invalid package file') unless valid_package_file?

        extract_metadata(nuspec_file)
      end

      private

      def package_file
        strong_memoize(:package_file) do
          ::Packages::PackageFile.find_by_id(@package_file_id)
        end
      end

      def valid_package_file?
        package_file &&
          package_file.package&.nuget? &&
          package_file.file.size.positive?
      end

      def extract_metadata(file)
        doc = Nokogiri::XML(file)

        XPATHS.map { |key, query| [key, doc.xpath(query).text] }
              .to_h
              .tap do |metadata|
                metadata[:package_dependencies] = extract_dependencies(doc)
              end
      end

      def extract_dependencies(doc)
        dependencies = []

        doc.xpath(XPATH_DEPENDENCIES).each do |node|
          dependencies << extract_dependency(node)
        end

        doc.xpath(XPATH_DEPENDENCY_GROUPS).each do |group_node|
          target_framework = group_node.attr("targetFramework")

          group_node.xpath("xmlns:dependency").each do |node|
            dependencies << extract_dependency(node).merge(target_framework: target_framework)
          end
        end

        dependencies
      end

      def extract_dependency(node)
        {
          name: node.attr('id'),
          version: node.attr('version')
        }.compact
      end

      def nuspec_file
        package_file.file.use_file do |file_path|
          Zip::File.open(file_path) do |zip_file|
            entry = zip_file.glob('*.nuspec').first

            raise ExtractionError.new('nuspec file not found') unless entry
            raise ExtractionError.new('nuspec file too big') if entry.size > MAX_FILE_SIZE

            entry.get_input_stream.read
          end
        end
      end
    end
  end
end
