# frozen_string_literal: true

module Gitlab
  module Database
    module Reindexing
      class ReindexAction < ApplicationRecord
        self.table_name = 'postgres_reindex_actions'

        def self.keep_track_of(index, &block)
          action = create!(
            index_identifier: index.identifier,
            reindex_start: Time.zone.now,
            ondisk_size_bytes_start: index.ondisk_size_bytes
          )

          yield

          index.reset

          action.reindex_end = Time.zone.now
          action.ondisk_size_bytes_end = index.ondisk_size_bytes

          action.save!
        end
      end
    end
  end
end
