# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicsAwardEmojiPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicsAwardEmojiQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

          def transform(_, data)
            nodes = data.dig('award_emoji', 'nodes')

            return if nodes.blank?

            track_next_page(data)

            data['award_emoji']['nodes'] = nodes.map do |node|
              ::BulkImports::Common::Transformers::UserReferenceTransformer.new.transform(context, node)
            end

            data
          end

          def load(context, data)
            return unless data

            epic = context.group.epics.find_by_iid(data['iid'])

            return unless epic

            raise NotAllowedError unless Ability.allowed?(context.current_user, :award_emoji, epic)

            data.dig('award_emoji', 'nodes').each do |award_emoji|
              next if award_emoji_exists?(epic, award_emoji)

              epic.award_emoji.create!(award_emoji)
            end
          end

          def on_complete
            pipeline_tracker = context.entity.trackers.create!(
              pipeline_name: EpicAwardEmojiPipeline.name,
              stage: context.tracker.stage
            )

            new_context = ::BulkImports::Pipeline::Context.new(pipeline_tracker)
            new_context.extra = context.extra

            EpicAwardEmojiPipeline.new(new_context).run
          end

          private

          def award_emoji_exists?(epic, data)
            epic.award_emoji.exists?(user_id: data['user_id'], name: data['name']) # rubocop: disable CodeReuse/ActiveRecord
          end

          def track_next_page(data)
            page_info = data.dig('award_emoji', 'page_info')

            if page_info['has_next_page']
              epic_iid = data['iid']
              award_emoji_next_page = page_info['next_page']
              context.extra[:subrelation_next_pages] ||= []
              context.extra[:subrelation_next_pages] << [epic_iid, award_emoji_next_page]
            end
          end
        end
      end
    end
  end
end
