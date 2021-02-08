# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module External
        module File
          class Template < Base
            attr_reader :location, :project, :version

            SUFFIX = '.gitlab-ci.yml'

            AVILABLE_VERSION_TAGS = %w[stable latest stable-or-latest]
            AVILABLE_VERSION_REGEXP = %r{v\d+\.\d+\.\d+}.freeze

            def initialize(params, context)
              @location = params[:template]
              @version = params[:version]

              super
            end

            def content
              strong_memoize(:content) { fetch_template_content }
            end

            private

            def validate_location!
              super

              if specific_template?
                unless template_name_valid?
                  errors.push("Template file `#{location}` is not a valid location!")
                end
              else versioned_template?
                unless version_valid?
                  errors.push("Template file `#{location}` is not a valid location!")
                end
              end
            end

            def template_name
              return unless template_name_valid?

              location.delete_suffix(SUFFIX)
            end

            def template_name_valid?
              location.to_s.end_with?(SUFFIX)
            end

            def specific_template?
              version.nil?
            end

            def versioned_template?
              version.present?
            end

            def version_valid?
              AVILABLE_VERSION_TAGS.include?(version) || version =~ AVILABLE_VERSION_REGEXP
            end

            def fetch_template_content
              Gitlab::Template::GitlabCiYmlTemplate.find(template_name, project, version: version)&.content
            end
          end
        end
      end
    end
  end
end
