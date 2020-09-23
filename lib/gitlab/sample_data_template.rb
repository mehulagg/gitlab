# frozen_string_literal: true

module Gitlab
  class SampleDataTemplate < ProjectTemplate
    def self.localized_templates_table
      [
        SampleDataTemplate.new('sample_data_template', 'Sample Data (test)', _('Test template for Sample Data.'), 'https://gitlab.com/gitlab-org/project-templates', 'illustrations/gitlab_logo.svg')
      ].freeze
    end

    class << self
      def all
        localized_templates_table
      end

      def archive_directory
        Rails.root.join("vendor/sample_data_templates")
      end
    end
  end
end
