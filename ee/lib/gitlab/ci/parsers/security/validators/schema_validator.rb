# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        module Validators
          class SchemaValidator
            class Schema
              ROOT_PATH = File.join(__dir__, 'schemas')

              def initialize(report_type)
                @report_type = report_type
              end

              delegate :validate, to: :schemer

              private

              attr_reader :report_type

              def schemer
                JSONSchemer.schema(pathname)
              end

              def pathname
                Pathname.new(schema_path)
              end

              def schema_path
                File.join(ROOT_PATH, file_name)
              end

              def file_name
                "#{report_type}.json"
              end
            end

            def initialize(report_type, report_data)
              @report_type = report_type
              @report_data = report_data
            end

            def valid?
              errors.empty?
            end

            def errors
              @errors ||= schema.validate(report_data).map { |error| JSONSchemer::Errors.pretty(error) }
            end

            private

            attr_reader :report_type, :report_data

            def schema
              Schema.new(report_type)
            end
          end
        end
      end
    end
  end
end
