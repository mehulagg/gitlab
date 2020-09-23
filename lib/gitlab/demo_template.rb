# frozen_string_literal: true

module Gitlab
  class DemoTemplate < ProjectTemplate
    def self.localized_templates_table
      [
        DemoTemplate.new('demo_template', 'Demo Template (test)', _('Test template for Demo Templates.'), 'https://gitlab.com/gitlab-org/project-templates', 'illustrations/gitlab_logo.svg')
      ].freeze
    end

    class << self
      def all
        localized_templates_table
      end

      def archive_directory
        Rails.root.join("vendor/demo_templates")
      end
    end
  end
end
