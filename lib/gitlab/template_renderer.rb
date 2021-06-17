# frozen_string_literal: true

module Gitlab
  module TemplateRenderer
    DEFAULT_TEMPLATE_FILE_EXT = 'tt'

    extend ActiveSupport::Concern

    class_methods do
      attr_reader :template_renderer_path

      def set_template_renderer_path(path)
        safe_path_as_array = Array(path).join('/').split('/')
        @template_renderer_path = Rails.root.join(*safe_path_as_array)
      end
    end

    def render_template_file(template_file_name, ext: DEFAULT_TEMPLATE_FILE_EXT)
      base_template_renderer_path = self.class.template_renderer_path
      if base_template_renderer_path.nil?
        raise ArgumentError, 'no template renderer path has been set using `set_template_renderer_path`'
      end

      template_file_name_with_ext = [template_file_name, ext].compact.join('.')
      full_template_file_name = base_template_renderer_path.join(template_file_name_with_ext)
      render_template_content(File.read(full_template_file_name))
    end

    def render_template_content(template_content)
      ERB.new(template_content, trim_mode: '<>').result(binding)
    end
  end
end
