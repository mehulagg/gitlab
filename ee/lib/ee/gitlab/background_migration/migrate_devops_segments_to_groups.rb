# frozen_string_literal: true
#
module EE
  module Gitlab
    module BackgroundMigration
      module MigrateDevopsSegmentsToGroups
        class AdoptionSegmentSelection < ActiveRecord::Base
          self.table_name = 'analytics_devops_adoption_segment_selections'
        end

        class AdoptionSegment < ActiveRecord::Base
          SNAPSHOT_CALCULATION_DELAY = 60.seconds

          self.table_name = 'analytics_devops_adoption_segments'

          has_many :selections, class_name: 'AdoptionSegmentSelection', foreign_key: :segment_id

          scope :without_namespace_id, -> { where(namespace_id: nil) }

          after_commit :schedule_data_calculation, on: :create

          private

          def schedule_data_calculation
            ::Analytics::DevopsAdoption::CreateSnapshotWorker.perform_in(SNAPSHOT_CALCULATION_DELAY + rand(10), id)
          end
        end

        def perform
          ActiveRecord::Base.transaction do
            AdoptionSegment
              .without_namespace_id
              .includes(:selections)
              .sort_by { |segment| segment.selections.size }
              .each do |segment|
              if segment.selections.size == 1
                group_id = segment.selections.first.group_id

                if segment_exists?(group_id)
                  segment.delete
                else
                  segment.update(namespace_id: group_id)
                end
              else
                segment.selections.each do |selection|
                  unless segment_exists?(selection.group_id)
                    AdoptionSegment.create(namespace_id: selection.group_id)
                  end
                end
                segment.delete
              end
            end
          end
        end

        private

        def segment_exists?(namespace_id)
          AdoptionSegment.where(namespace_id: namespace_id).exists?
        end
      end
    end
  end
end
