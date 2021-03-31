# frozen_string_literal: true

require 'rails/generators'

module Gitlab
  class SnowplowEventDefinitionGenerator < Rails::Generators::Base
    TOP_LEVEL_DIR = 'config'

    source_root File.expand_path('../../../generator_templates/snowplow_event_definition', __dir__)

    desc 'Generates a metric definition yml file'

    def create_metric_file
      template "event_definition.yml", file_path
    end

    private

    def file_path
      File.join(TOP_LEVEL_DIR, 'events', "#{file_name}.yml")
    end

    def file_name
      "#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"
    end
  end
end
