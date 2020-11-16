# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    class RemoveOrphanServiceHooks
      class WebHook < ActiveRecord::Base
        include EachBatch

        self.table_name = 'web_hooks'

        def self.service_hooks
          where(type: 'ServiceHook')
        end
      end

      class Service < ActiveRecord::Base
        self.table_name = 'services'
      end

      def perform
        WebHook.service_hooks.where.not(service_id: Service.select(:id)).each_batch do |relation|
          relation.delete_all
        end
      end
    end
  end
end
