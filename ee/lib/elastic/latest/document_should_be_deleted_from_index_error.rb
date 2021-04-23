# frozen_string_literal: true

module Elastic
  module Latest
    class DocumentShouldBeDeletedFromIndexError < StandardError
      attr_reader :class_name, :record_id

      def initialize(class_name, record_id)
        @class_name = class_name
        @record_id = record_id
      end

      def message
        "#{class_name} with id #{record_id} should be deleted from the index."
      end
    end
  end
end
