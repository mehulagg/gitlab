# frozen_string_literal: true

module Packages
  module Maven
    module Metadata
      class SyncVersionsXmlFromDatabaseService
        include Gitlab::Utils::StrongMemoize

        XPATH_VERSIONING = '//metadata/versioning'
        XPATH_VERSIONS = '//versions'
        XPATH_VERSION = '//version'
        XPATH_LATEST = '//latest'
        XPATH_RELEASE = '//release'
        XPATH_LAST_UPDATED = '//lastUpdated'

        INDENT_SPACE = 2

        def initialize(metadata_content:, package:)
          @metadata_content = metadata_content
          @package = package
        end

        def execute
          return ServiceResponse.error(message: 'package not set') unless @package
          return ServiceResponse.error(message: 'metadata_content not set') unless @metadata_content
          return ServiceResponse.error(message: 'metadata_content is invalid') unless valid_metadata_content?

          changes_exist = false
          changes_exist = true if update_versions_list
          changes_exist = true if update_latest
          changes_exist = true if update_release
          update_last_updated_timestamp if changes_exist

          payload = { changes_exist: changes_exist }
          payload[:metadata_content] = xml_doc.to_xml(indent: INDENT_SPACE) if changes_exist

          ServiceResponse.success(payload: payload)
        end

        private

        def valid_metadata_content?
          versioning_xml_node.present? &&
            versions_xml_node.present? &&
            release_xml_node.present? &&
            last_updated_xml_node.present?
        end

        def update_versions_list
          removed = remove_superfluous_versions
          added = add_missing_versions

          removed || added
        end

        def remove_superfluous_versions
          superfluous_versions.each do |superfluous_version|
            versions_xml_node.xpath("//version[text()='#{superfluous_version}']")
                             .first
                             .remove
          end

          superfluous_versions.any?
        end

        def add_missing_versions
          return false if missing_versions.empty?

          last_version_node = versions_xml_node.xpath(XPATH_VERSION).last
          missing_versions.each do |missing_version|
            last_version_node.add_next_sibling(version_node_for(missing_version))
          end
          true
        end

        def update_latest
          return false if missing_versions.empty? || latest_coherent?

          latest_xml_node.content = latest_from_database
          true
        end

        def latest_coherent?
          latest_from_xml.nil? || latest_from_xml == latest_from_database
        end

        def update_release
          return false if missing_versions.empty? || release_coherent?

          release_xml_node.content = release_from_database
          true
        end

        def release_coherent?
          release_from_xml == release_from_database
        end

        def update_last_updated_timestamp
          last_updated_xml_node.content = Time.now.strftime('%Y%m%d%H%M%S')
        end

        def versioning_xml_node
          strong_memoize(:versioning_xml_node) do
            xml_doc.xpath(XPATH_VERSIONING).first
          end
        end

        def versions_xml_node
          strong_memoize(:versions_xml_node) do
            versioning_xml_node&.xpath(XPATH_VERSIONS)
                               &.first
          end
        end

        def latest_xml_node
          strong_memoize(:latest_xml_node) do
            versioning_xml_node&.xpath(XPATH_LATEST)
                               &.first
          end
        end

        def release_xml_node
          strong_memoize(:release_xml_node) do
            versioning_xml_node&.xpath(XPATH_RELEASE)
                               &.first
          end
        end

        def last_updated_xml_node
          strong_memoize(:last_updated_xml_mode) do
            versioning_xml_node.xpath(XPATH_LAST_UPDATED)
                               .first
          end
        end

        def version_node_for(version)
          Nokogiri::XML::Node.new('version', xml_doc).tap { |node| node.content = version }
        end

        def superfluous_versions
          strong_memoize(:superfluous_versions) do
            versions_from_xml - versions_from_database
          end
        end

        def missing_versions
          strong_memoize(:missing_versions) do
            versions_from_database - versions_from_xml
          end
        end

        def versions_from_xml
          strong_memoize(:versions_from_xml) do
            versions_xml_node.xpath(XPATH_VERSION)
                             .map(&:text)
          end
        end

        def latest_from_xml
          latest_xml_node&.text
        end

        def release_from_xml
          release_xml_node&.text
        end

        def versions_from_database
          strong_memoize(:versions_from_database) do
            @package.project.packages
                            .maven
                            .processed
                            .with_name(@package.name)
                            .has_version
                            .order_created
                            .pluck_versions
          end
        end

        def latest_from_database
          versions_from_database.last
        end

        def release_from_database
          non_snapshot_versions_from_database = versions_from_database.reject { |v| v.ends_with?('SNAPSHOT') }
          non_snapshot_versions_from_database.last
        end

        def xml_doc
          strong_memoize(:xml_doc) do
            Nokogiri::XML(@metadata_content) do |config|
              config.default_xml.noblanks
            end
          end
        end
      end
    end
  end
end
