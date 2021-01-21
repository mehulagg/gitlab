# frozen_string_literal: true
# rubocop:disable Graphql/AuthorizeTypes

module Types
  module Admin
    module Analytics
      module DevopsAdoption
        class SegmentType < BaseObject
          graphql_name 'DevopsAdoptionSegment'
          description 'Segment'

          field :id, GraphQL::ID_TYPE, null: false,
                description: "ID of the segment"

          field :namespace, Types::NamespaceType, null: true, description: 'Segment namespace'

          field :latest_snapshot, SnapshotType, null: true,
                description: 'The latest adoption metrics for the segment'

          def latest_snapshot
            BatchLoader::GraphQL.for(object.id).batch(key: :devops_adoption_latest_snapshots) do |ids, loader, args|
              snapshots = ::Analytics::DevopsAdoption::Snapshot
                .latest_snapshot_for_segment_ids(ids)
                .index_by(&:segment_id)

              ids.each do |id|
                loader.call(id, snapshots[id])
              end
            end
          end
        end
      end
    end
  end
end
