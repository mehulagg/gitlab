# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Coverage
        class Cobertura
          CoberturaParserError = Class.new(Gitlab::Ci::Parsers::ParserError)

          GO_SOURCE_PATTERN = '/usr/local/go/src'

          def parse!(xml_data, coverage_report, project_path:, worktree_paths:)
            root = Hash.from_xml(xml_data)

            context = {
              project_path: project_path,
              paths: worktree_paths.to_set,
              sources: []
            }

            parse_all(root, coverage_report, context)
          rescue Nokogiri::XML::SyntaxError
            raise CoberturaParserError, "XML parsing failed"
          rescue
            raise CoberturaParserError, "Cobertura parsing failed"
          end

          private

          def parse_all(root, coverage_report, context)
            return unless root.present?

            root.each do |key, value|
              parse_node(key, value, coverage_report, context)
            end
          end

          def parse_node(key, value, coverage_report, context)
            if key == 'sources' && value['source'].present?
              parse_sources(value['source'], context)
            elsif key == 'package'
              Array.wrap(value).each do |item|
                parse_package(item, coverage_report, context)
              end
            elsif value.is_a?(Hash)
              parse_all(value, coverage_report, context)
            elsif value.is_a?(Array)
              value.each do |item|
                parse_all(item, coverage_report, context)
              end
            end
          end

          def parse_sources(sources, context)
            sources = Array.wrap(sources)

            # TODO: Go cobertura has a different format with how their packages
            # are included in the filename. So we can't rely on the sources.
            # We'll deal with this later.
            return if sources.include?(GO_SOURCE_PATTERN)

            sources.each do |source|
              # | raw source                  | extracted  |
              # |-----------------------------|------------|
              # | /builds/foo/test/SampleLib/ | SampleLib/ |
              # | /builds/foo/test/something  | something  |
              # | /builds/foo/test/           | nil        |
              # | /builds/foo/test            | nil        |
              source = source.split("#{context[:project_path]}/", 2)[1]
              context[:sources] << source if source.present?
            end
          end

          def parse_package(package, coverage_report, context)
            return unless package['name'].present?

            classes = package.dig('classes', 'class')
            return unless classes.present?

            determined_filenames = Array.wrap(classes).map do |item|
              parse_class(package, item, coverage_report, context)
            end

            # Remove these filenames from the paths to avoid conflict
            # with other packages that may contain the same class filenames
            determined_filenames.each { |f| context[:paths].delete(f) }
          end

          def parse_class(package, file, coverage_report, context)
            return unless file["filename"].present? && file["lines"].present?

            parsed_lines = parse_lines(file["lines"])
            filename = determine_filename(file["filename"], context)

            coverage_report.add_file(filename, Hash[parsed_lines]) if filename

            filename
          end

          def parse_lines(lines)
            line_array = Array.wrap(lines["line"])

            line_array.map do |line|
              # Using `Integer()` here to raise exception on invalid values
              [Integer(line["number"]), Integer(line["hits"])]
            end
          end

          def determine_filename(filename, context)
            return filename unless context[:sources].any?

            full_filename = nil

            context[:sources].each do |source|
              full_path = File.join(source, filename)

              if context[:paths].include?(full_path)
                full_filename = full_path

                break
              end
            end

            full_filename
          end
        end
      end
    end
  end
end
