# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicEventsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
                    query: EE::BulkImports::Groups::Graphql::GetEpicEventsQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer
          transformer ::BulkImports::Common::Transformers::UserReferenceTransformer, reference: 'author'

          def initialize(context)
            @context = context
            @group = context.group
            @epic_iids = @group.epics.order(iid: :desc).pluck(:iid) # rubocop: disable CodeReuse/ActiveRecord

            set_next_epic
          end

          def transform(context, data)
            # Only create 'reopened' & 'closed' events.
            # 'created' event get created when epic is persisted.
            # Avoid creating duplicates & protect from additional
            # potential undesired events.
            return unless data['action'] == 'REOPENED' || data['action'] == 'CLOSED'

            data.merge!(
              'group_id' => context.group.id,
              'action' => data['action'].downcase
            )
          end

          def load(context, data)
            return unless data

            epic = context.group.epics.find_by_iid(context.extra[:epic_iid])

            return unless epic

            ::Event.transaction do
              create_event!(epic, data)
              create_resource_state_event!(epic, data)
            end
          end

          def after_run(extracted_data)
            tracker.update(
              has_next_page: extracted_data.has_next_page?,
              next_page: extracted_data.next_page
            )

            set_next_epic unless extracted_data.has_next_page?

            if extracted_data.has_next_page? || context.extra[:epic_iid]
              run
            end
          end

          private

          def set_next_epic
            context.extra[:epic_iid] = @epic_iids.pop
          end

          def create_event!(epic, data)
            epic.events.create!(data)
          end

          # In order for events to be shown in the UI we need to create
          # `ResourceStateEvent` record
          def create_resource_state_event!(epic, data)
            state_event_data = {
              user_id: data['author_id'],
              state: data['action'],
              created_at: data['created_at']
            }

            epic.resource_state_events.create!(state_event_data)
          end
        end
      end
    end
  end
end
