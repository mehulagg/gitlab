# frozen_string_literal: true

module Banzai
  module ReferenceParser
    class MentionedUserParser < BaseParser
      self.reference_type = :user

      # any user can be mentioned by username
      def can_read_reference?(user, ref_attr, node)
        true
      end
    end
  end
end
