# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Transformers
        class EpicAwardEmojiTransformer
          def initialize(*args); end

          def transform(context, data)
            data
              .then { |data| add_user_id(context, data) }
          end

          private

          # rubocop: disable CodeReuse/ActiveRecord
          def add_user_id(context, data)
            epic = context.group.epics.find_by(iid: context.extra[:epic_iid])
            user = find_user(context, data&.dig('user', 'public_email'))

            return unless epic
            return unless user
            return unless user_is_group_member?(context, user)
            return if award_emoji_exists?(epic, user, data)

            data
              .except('user')
              .merge('user_id' => user.id)
          end

          def find_user(context, email)
            return unless email

            ::User.find_by_any_email(email, confirmed: true) || context.current_user
          end

          def user_is_group_member?(context, user)
            context.group.members.find_by(user_id: user.id)
          end

          # Do not attempt to create duplicate emoji
          # since duplicates are not allowed
          def award_emoji_exists?(epic, user, data)
            epic.award_emoji.find_by(user_id: user.id, name: data['name'])
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
