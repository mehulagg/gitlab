# frozen_string_literal: true

module Elastic
  module MigrationOptions
    extend ActiveSupport::Concern
    include Gitlab::ClassAttributes

    DEFAULT_THROTTLE_DELAY = 5.minutes

    def migration_options
      self.class.get_migration_options
    end

    class_methods do
      def migration_options(opts = { throttle_delay: DEFAULT_THROTTLE_DELAY })
        class_attributes[:migration_options] = opts
      end

      def get_migration_options
        class_attributes[:migration_options] || {}
      end
    end
  end
end
