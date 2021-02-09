# frozen_string_literal: true

module Banzai
  module ReferenceParser
    class FeatureFlagParser < BaseParser
      self.reference_type = :feature_flag

      override :references_relation
      def self.references_relation
        Operations::FeatureFlag
      end

      private

      def can_read_reference?(user, feature_flag, node)
        can?(user, :read_feature_flag, feature_flag)
      end
    end
  end
end
