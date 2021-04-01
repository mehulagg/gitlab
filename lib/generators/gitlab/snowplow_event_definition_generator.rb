# frozen_string_literal: true

require 'rails/generators'

module Gitlab
  class SnowplowEventDefinitionGenerator < Rails::Generators::Base
    TOP_LEVEL_DIR = 'config'
    TOP_LEVEL_DIR_EE = 'ee'

    source_root File.expand_path('../../../generator_templates/snowplow_event_definition', __dir__)

    desc 'Generates a metric definition yml file'

    class_option :category, type: :string, optional: false, desc: 'Category of the event'
    class_option :ee, type: :boolean, optional: true, default: false, desc: 'Indicates if event is for ee'

    def create_event_file
      template "event_definition.yml", file_path
    end

    private

    def file_path
      path = File.join(TOP_LEVEL_DIR, 'events', "#{file_name}.yml")
      path = File.join(TOP_LEVEL_DIR_EE, path) if ee?
      path
    end

    def file_name
      "#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{options[:category]}"
    end

    def ee?
      options[:ee]
    end
  end
end
