# frozen_string_literal: true

require 'rails/generators'

class UsageMetricDefinitionGenerator < Rails::Generators::Base
  desc 'Generates a metric definition yml file'

  class_option :ee, type: :string, optional: true, desc: 'Indicates if metric is for ee'
  class_option :settings, type: :string, desc: 'Indicates if metric is a setting'
  class_option :license, type: :string, desc: 'Indicates if metric is related with license data'
  class_option :time_frame, type: :string, default: 'none', desc: 'Indicates metric data time frame. One of 7d, 28d, all, none'

  argument :key_path, type: :string, desc: 'Unique JSON key path for the metric'

  def create_metric_file
    path = File.join('config', 'metrics', folder, "#{file_name}.yml")
    path = File.join('ee', 'config', 'metrics', folder, "#{file_name}.yml") if ee?

    template "metric_definition.yml", path
  end

  def ee?
    options[:ee] == 'ee'
  end

  def settings?
    options[:settings] == 'settings'
  end

  def license?
    options[:license] == 'license'
  end

  def file_name
    key_path.split('.').last
  end

  def time_frame
    options[:time_frame]
  end

  def time_frame_folder
    case time_frame
    when '7d'
      'counts_7d'
    when '28d'
      'counts_28d'
    when 'all'
      'counts_all'
    end
  end

  def folder
    folder = time_frame_folder
    folder = 'license'  if license?
    folder = 'settings' if settings?
    folder
  end
end
