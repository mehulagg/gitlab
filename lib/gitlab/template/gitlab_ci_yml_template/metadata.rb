# frozen_string_literal: true

module Gitlab
  module Template
    class GitlabCiYmlTemplate < BaseTemplate
      class Metadata
        METADATA_ANCHOR = '.cicd-template-metadata'
        PROPERTIES = %w[name description type group ignore_guideline_violation input].freeze

        attr_reader :metadata_content

        def initialize(ci_yaml)
          @metadata_content = ci_yaml[METADATA_ANCHOR]
        end

        def exist?
          metadata_content.present?
        end

        def valid?
          validation_errors.empty?
        end

        def validation_errors
          @validation_errors ||= validator.validate(metadata_content).to_a
        end

        def self.placeholder(name:)
          name = name.gsub('.gitlab-ci.yml', '')
          type = name.include?('/') ? 'job' : 'pipeline'
          # TODO: We will follow up to fix the guideline violation in the future.
          <<~EOS
            # This is a CI/CD template maintained by GitLab.
            # For more information, see https://docs.gitlab.com/ee/development/cicd/templates.html.
            .cicd-template-metadata:
                name: #{name}
                description: This is a CI/CD template for <purpose> ...
                type: #{type}
                group: group::your-group
                ignore_guideline_violation: true

          EOS
        end

        PROPERTIES.each do |key|
          define_method(key) do
            metadata_content[key]
          end
        end

        private

        def validator
          @validator ||= JSONSchemer.schema(Pathname.new(schema_path))
        end

        def schema_path
          Rails.root.join('lib/gitlab/template/gitlab_ci_yml_template/schema.json')
        end
      end
    end
  end
end
