# frozen_string_literal: true

module Gitlab
  module Usage
    module Docs
      # Helper with functions to be used by HAML templates
      module Helper
        HEADER = %w(field value).freeze
        SKIP_KEYS = %i(description).freeze

        def auto_generated_comment
          <<-MARKDOWN.strip_heredoc
            ---
            stage: Growth
            group: Product Intelligence
            info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
            ---

            <!---
              This documentation is auto generated by a script.

              Please do not edit this file directly, check generate_metrics_dictionary task on lib/tasks/gitlab/usage_data.rake.
            --->
          MARKDOWN
        end

        def render_name(name)
          "## #{name}\n"
        end

        def render_description(object)
          object.description
        end

        def render_attribute_row(key, value)
          value = Gitlab::Usage::Docs::ValueFormatter.format(key, value)
          table_row(["`#{key}`", value])
        end

        def render_attributes_table(object)
          <<~MARKDOWN

            #{table_row(HEADER)}
            #{table_row(HEADER.map { '---' })}
            #{table_value_rows(object.attributes)}
          MARKDOWN
        end

        def table_value_rows(attributes)
          attributes.reject { |k, _| k.in?(SKIP_KEYS) }.map do |key, value|
            render_attribute_row(key, value)
          end.join("\n")
        end

        def table_row(array)
          "| #{array.join(' | ')} |"
        end
      end
    end
  end
end
