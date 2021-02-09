# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Loaders
        class EpicAwardEmojiLoader
          NotAllowedError = Class.new(StandardError)

          def initialize(options = {})
            @options = options
          end

          # rubocop: disable CodeReuse/ActiveRecord
          def load(context, data)
            return unless data

            epic = context.group.epics.find_by(iid: context.extra[:epic_iid])
            user = ::User.find_by(id: data['user_id'])

            raise NotAllowedError unless Ability.allowed?(user, :award_emoji, epic)

            epic.award_emoji.create!(data)
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
