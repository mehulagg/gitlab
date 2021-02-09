# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Transformers
        class EpicAwardEmojiTransformer
          def initialize(*args); end

          def transform(context, data)
            data.then { |data| add_user_id(context, data) }
          end

          private

          def add_user_id(context, data)
            user = find_user(context, data&.dig('user', 'public_email'))

            return unless user
            return unless user_is_group_member?(context, user)

            data
              .except('user')
              .merge('user_id' => user.id)
          end

          def find_user(context, email)
            return unless email

            ::User.find_by_any_email(email, confirmed: true) || context.current_user
          end

          def user_is_group_member?(context, user)
            context.group.members.find_by(user_id: user.id) # rubocop: disable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
