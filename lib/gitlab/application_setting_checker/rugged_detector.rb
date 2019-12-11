# frozen_string_literal: true

module Gitlab
  module ApplicationSettingChecker
    class RuggedDetector
      def self.sample_storages
        Project.sample_storages
      end

      def self.rugged_feature_keys
        [
          :rugged_commit_is_ancestor,
          :rugged_tree_entry,
          :rugged_find_commit,
          :rugged_list_commits_by_oid,
          :rugged_commit_tree_entry,
          :rugged_tree_entries
        ]
      end

      def self.feature_enabled_any?(feature_keys)
        feature_keys.each do |feature_key|
          feature = Feature.get(feature_key)
          return true if Feature.persisted?(feature) && feature.enabled?
        end

        false
      end

      def self.gitaly_can_use_disk_storage_any?(storages)
        storages.each do |storage|
          return true if Gitlab::GitalyClient.can_use_disk?(storage)
        end

        false
      end

      def self.rugged_enabled?
        feature_enabled_any?(rugged_feature_keys) || gitaly_can_use_disk_storage_any?(sample_storages)
      end
    end
  end
end
