module EE
  module Gitlab
    module BackgroundMigration
      class MigrateDevopsSegmentsToGroups
        class AdoptionSegmentSelection < ActiveRecord::Base
          self.table_name = 'analytics_devops_adoption_segment_selections'
        end

        class AdoptionSegment < ActiveRecord::Base
          self.table_name = 'analytics_devops_adoption_segments'

          has_many :selections, class_name: 'AdoptionSegmentSelection', foreign_key: :segment_id

          scope :without_namespace_id, -> { where(namespace_id: nil) }
        end

        def perform
          ActiveRecord::Base.transaction do
            AdoptionSegment
              .without_namespace_id
              .includes(:selections)
              .sort_by { |segment| segment.selections.size }
              .each do |segment|
              case segment.selections.size
              when 1 then
                segment.update(namespace_id: segment.selections.first.group_id)
              else
                segment.selections.each do |selection|
                  unless AdoptionSegment.where(namespace_id: selection.group_id).exists?
                    AdoptionSegment.create!(namespace_id: selection.group_id)
                  end
                end
                segment.delete
              end
            end
          end
        end
      end
    end
  end
end
