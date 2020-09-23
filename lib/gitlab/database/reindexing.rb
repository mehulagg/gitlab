# frozen_string_literal: true

module Gitlab
  module Database
    module Reindexing
      def self.perform(index_selector)
        indexes = [index_selector].flatten

        indexes.each do |index|
          ReindexAction.keep_track_of(index) do
            ConcurrentReindex.new(index).perform
          end
        end
      end
    end
  end
end
