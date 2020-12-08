# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Remove duplicated service records with the same project and type.
    # These were created in the past for unknown reasons, and should be blocked
    # now by the uniqueness validation in the Service model.
    class RemoveDuplicateServices
      # See app/models/project
      class Project < ActiveRecord::Base
        include EachBatch

        self.table_name = 'projects'

        has_many :services
        scope :with_services, -> { distinct.joins(:services).where.not(services: { id: nil }) }

        # Lookup by type instead of to_param, so we don't need to reference the service classes.
        # The order should still be the same.
        def find_service(type)
          services.find { |service| service.type == type }
        end
      end

      # See app/models/service
      class Service < ActiveRecord::Base
        include EachBatch

        self.table_name = 'services'
        self.inheritance_column = :_type_disabled
      end

      def perform(start_id, end_id)
        projects_with_services = Project.with_services.where(id: (start_id..end_id))

        projects_with_services.each do |project|
          process(project)
        end
      end

      private

      def process(project)
        types = project.services.map(&:type)
        return unless types.present?

        unique_types = types.uniq
        return if unique_types.size == types.size

        unique_types.each do |type|
          # Get the currently used service record, without imposing an order on the query.
          # This matches the application code and should usually stay the same between queries,
          # although it can change at any time (due to e.g. storage changes).
          current_service = project.find_service(type)
          next unless current_service

          # Delete any other services of the same type
          duplicate_services = project.services.where(type: type).where.not(id: current_service.id)
          count = duplicate_services.count
          next unless count > 0

          logger.warn(
            message: "Deleting #{count} duplicate services",
            migrator: 'RemoveDuplicateServices',
            project_id: project.id,
            service: type
          )

          duplicate_services.delete_all
        end
      end

      def logger
        @logger ||= ::Gitlab::BackgroundMigration::Logger.build
      end
    end
  end
end
