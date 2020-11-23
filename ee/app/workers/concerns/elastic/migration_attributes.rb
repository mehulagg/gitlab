# frozen_string_literal: true

module Elastic
  module MigrationAttributes
    extend ActiveSupport::Concern
    include Gitlab::ClassAttributes

    DEFAULT_THROTTLE_TIME = 5.minutes

    def migration_options
      self.class.get_migration_options
    end

    class_methods do
      def migration_options(opts = { throttle_time: DEFAULT_THROTTLE_TIME })
        class_attributes[:migration_options] = opts
      end

      def get_migration_options
        class_attributes[:migration_options] || {}
      end
    end
  end
end
