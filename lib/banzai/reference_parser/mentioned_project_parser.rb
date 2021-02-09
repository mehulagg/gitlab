# frozen_string_literal: true

module Banzai
  module ReferenceParser
    class MentionedProjectParser < ProjectParser
      PROJECT_ATTR = 'data-project'

      self.reference_type = :user

      def self.data_attribute
        @data_attribute ||= PROJECT_ATTR
      end

      override :references_relation
      def self.references_relation
        Project
      end
    end
  end
end
