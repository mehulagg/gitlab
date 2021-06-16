# frozen_string_literal: true

module Gitlab
  module FormBuilders
    class GitlabUiFormBuilder < ActionView::Helpers::FormBuilder
      def gitlab_ui_checkbox(method, label, help_text: nil, checkbox_options: {}, label_options: {})
        @template.content_tag(
          :div,
          class: 'gl-form-checkbox custom-control custom-checkbox'
        ) do
          @template.check_box(
            @object_name, method, objectify_options(options_with_merged_css_classes(checkbox_options, ['custom-control-input']))
          ) +
          @template.label(
            @object_name, method, objectify_options(options_with_merged_css_classes(label_options, ['custom-control-label']))
          ) do
            @template.content_tag(
              :span,
              label
            ) +
            @template.content_tag(
              :p,
              help_text,
              class: 'help-text',
            )
          end
        end
      end

      private

      def options_with_merged_css_classes(options, classes, class_key = :class)
        classes << options[class_key]

        options.merge({ class_key => classes.flatten.compact })
      end
    end
  end
end
