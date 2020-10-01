# frozen_string_literal: true

module Gitlab
  module WhatsNew
    EMPTY_JSON = ''.to_json
    CACHE_DURATION = 1.day
    WHATS_NEW_FILES_PATH = Rails.root.join('data', 'whats_new', '*.yml')

    private

    def whats_new_most_recent_release_items
      Rails.cache.fetch('whats_new:release_items', expires_in: CACHE_DURATION) do
        file = File.read(most_recent_release_file_path)

        YAML.safe_load(file, permitted_classes: [Date]).to_json
      end
    rescue => e
      Gitlab::ErrorTracking.track_exception(e, yaml_file_path: most_recent_release_file_path)

      EMPTY_JSON
    end

    def most_recent_release_file_path
      @most_recent_release_file_path ||= Dir.glob(WHATS_NEW_FILES_PATH).max
    end
  end
end
