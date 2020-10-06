# frozen_string_literal: true

module Gitlab
  module WhatsNew
    EMPTY_JSON = ''.to_json
    CACHE_DURATION = 1.day
    WHATS_NEW_FILES_PATH = Rails.root.join('data', 'whats_new', '*.yml')

    private

    def whats_new_release_items(page: 1)
      #I think this can cause bad caches.
      Rails.cache.fetch("whats_new:release_items:page-#{page}", expires_in: CACHE_DURATION) do

        index = page - 1
        file_path = most_recent_release_file_paths[index]

        if file_path
          file = File.read(file_path)

          YAML.safe_load(file, permitted_classes: [Date]).to_json
        else
          EMPTY_JSON
        end
      end
    rescue => e
      #can this be file_path again
      Gitlab::ErrorTracking.track_exception(e, page: page)

      EMPTY_JSON
    end

    def most_recent_release_file_paths
      @most_recent_release_file_paths ||= Dir.glob(WHATS_NEW_FILES_PATH).sort.reverse
    end
  end
end
