# frozen_string_literal: true

module Banzai
  module ReferenceParser
    class MilestoneParser < BaseParser
      self.reference_type = :milestone

      private

      def can_read_reference?(user, ref_project, node)
        can?(user, :read_milestone, ref_project)
      end
    end
  end
end
