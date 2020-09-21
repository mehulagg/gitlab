# frozen_string_literal: true

module Gitlab
  module WhatsNew
    EMPTY_JSON = ''.to_json

    private

    def whats_new_most_recent_release_items
      YAML.load_file(most_recent_release_file_path).to_json

    rescue => e
      Gitlab::ErrorTracking.track_exception(e, yaml_file_path: most_recent_release_file_path)

      EMPTY_JSON
    end

    def most_recent_release_file_path
      Dir.glob(files_path).max
    end

    def files_path
      Rails.root.join('data', 'whats_new', '*.yml')
    end
  end
end
