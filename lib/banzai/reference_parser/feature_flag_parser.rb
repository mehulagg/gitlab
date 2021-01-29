# frozen_string_literal: true

module Banzai
  module ReferenceParser
    class FeatureFlagParser < BaseParser
      self.reference_type = :flag

      def references_relation
        Operations::FeatureFlag
      end

      private

      def can_read_reference?(user, flag, node)
        can?(user, :read_feature_flag, flag)
      end
    end
  end
end
