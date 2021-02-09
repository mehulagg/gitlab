# frozen_string_literal: true

module Banzai
  module ReferenceParser
    class LabelParser < BaseParser
      self.reference_type = :label

      private

      def can_read_reference?(user, ref_project, node)
        can?(user, :read_label, ref_project)
      end
    end
  end
end
