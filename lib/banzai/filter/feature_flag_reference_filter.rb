# frozen_string_literal: true

module Banzai
  module Filter
    class FeatureFlagReferenceFilter < IssuableReferenceFilter
      self.reference_type = :flag

      def self.object_class
        Operations::FeatureFlag
      end

      def self.object_sym
        :flag
      end

      def parent_records(parent, ids)
        parent.operations_feature_flags.where(iid: ids.to_a)
      end

      def url_for_object(alert, project)
        ::Gitlab::Routing.url_helpers.edit_project_feature_flag_url(
          project,
          flag.iid,
          only_path: context[:only_path]
        )
      end
    end
  end
end
