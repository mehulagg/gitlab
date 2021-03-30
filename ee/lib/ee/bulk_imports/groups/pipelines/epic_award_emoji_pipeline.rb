# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicAwardEmojiPipeline < EE::BulkImports::Pipeline::EpicBase
          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicAwardEmojiQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer
          transformer ::BulkImports::Common::Transformers::UserReferenceTransformer

          # rubocop: disable CodeReuse/ActiveRecord
          def load(context, data)
            return unless data

            epic = context.group.epics.find_by(iid: context.extra[:epic_iid])

            return if award_emoji_exists?(epic, data)

            raise NotAllowedError unless Ability.allowed?(context.current_user, :award_emoji, epic)

            epic.award_emoji.create!(data)
          end

          private

          def award_emoji_exists?(epic, data)
            epic.award_emoji.exists?(user_id: data['user_id'], name: data['name'])
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
