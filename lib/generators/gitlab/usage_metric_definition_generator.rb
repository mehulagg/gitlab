# frozen_string_literal: true

require 'rails/generators'

module Gitlab
  class UsageMetricDefinitionGenerator < Rails::Generators::Base
    Directory = Struct.new(:name, :time_frame) do
      def match?(str)
        (name == str || time_frame == str) && str != 'none'
      end
    end

    TIME_FRAME_DIRS = [
      Directory.new('counts_7d',  '7d'),
      Directory.new('counts_28d', '28d'),
      Directory.new('counts_all', 'all'),
      Directory.new('settings',   'none'),
      Directory.new('license',    'none')
    ].freeze

    VALID_INPUT_DIRS = (TIME_FRAME_DIRS.flat_map { |d| [d.name, d.time_frame] } - %w(none)).freeze

    source_root File.expand_path('../../../generator_templates/usage_metric_definition', __dir__)

    desc 'Generates a metric definition yml file'

    class_option :ee, type: :boolean, optional: true, default: false, desc: 'Indicates if metric is for ee'
    class_option :dir,
      type: :string, desc: "Indicates the metric location. It must be one of: #{VALID_INPUT_DIRS.join(', ')}"

    argument :key_path, type: :string, desc: 'Unique JSON key path for the metric'

    def create_metric_file
      validate!

      template "metric_definition.yml", file_path
    end

    def time_frame
      directory&.time_frame
    end

    def distribution
      value = ['ce']
      value << 'ee' if ee?
      value
    end

    private

    def file_path
      path = File.join('config', 'metrics', directory&.name, "#{file_name}.yml")
      path = File.join('ee', path) if ee?
      path
    end

    def validate!
      raise "--dir option is required" unless input_dir.present?
      raise "Invalid dir #{input_dir}, allowed options are #{VALID_INPUT_DIRS.join(', ')}" unless directory.present?
    end

    def ee?
      options[:ee]
    end

    def input_dir
      options[:dir]
    end

    def file_name
      "#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{key_path.split('.').last}"
    end

    def directory
      @directory ||= TIME_FRAME_DIRS.find { |d| d.match?(input_dir) }
    end
  end
end
