# frozen_string_literal: true

module Ci
  module BuildTraceChunks
    class Database
      def available?
        true
      end

      def persisted?
        true
      end

      def keys(relation)
        []
      end

      def delete_keys(keys)
        # no-op
      end

      def data(model)
        model.raw_data&.force_encoding(Encoding::BINARY)
      end

      def set_data(model, data)
        model.raw_data = data
      end

      def delete_data(model)
        model.update_columns(raw_data: nil) unless model.raw_data.nil?
      end
    end
  end
end
