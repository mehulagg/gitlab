# frozen_string_literal: true

require 'rails/generators'

module Gitlab
  class UsageMetricGenerator < Rails::Generators::Base
    CE_DIR = 'lib/gitlab/usage/metrics/instrumentations'
    EE_DIR = 'ee/lib/ee/gitlab/usage/metrics/instrumentations'
    SPEC_CE_DIR = 'spec/lib/gitlab/usage/metrics/instrumentations'
    SPEC_EE_DIR = 'ee/spec/lib/ee/gitlab/usage/metrics/instrumentations'

    ALLOWED_SUPERCLASSES = {
      generic: 'Generic',
      database: 'Database',
      redis_hll: 'RedisHLL'
    }.freeze

    source_root File.expand_path('../../../../generator_templates/usage_metric', __dir__)

    class_option :ee, type: :boolean, optional: true, default: false, desc: 'Indicates if instrumentation is for EE'
    class_option :type, type: :string, desc: "Metric type, must be one of: #{ALLOWED_SUPERCLASSES.keys.join(', ')}"

    argument :class_name, type: :string, desc: 'Instrumentation class name, e.g.: CountIssues'

    def create_class_file
      template "instrumentation_class.rb", file_path
    end

    def create_spec_file
      template "instrumentation_class_spec.rb", spec_file_path
    end

    private

    def ee?
      options[:ee]
    end

    def type
      options[:type]
    end

    def file_path
      dir = ee? ? EE_DIR : CE_DIR

      File.join(dir, file_name)
    end

    def spec_file_path
      dir = ee? ? SPEC_EE_DIR : SPEC_CE_DIR

      File.join(dir, spec_file_name)
    end

    def file_name
      "#{class_name.underscore}_metric.rb"
    end

    def spec_file_name
      "#{class_name.underscore}_metric_spec.rb"
    end

    def metric_superclass
      superclass = ALLOWED_SUPERCLASSES[type.to_sym]

      raise "Unknown metric type #{type}" if superclass.nil?

      superclass
    end
  end
end
