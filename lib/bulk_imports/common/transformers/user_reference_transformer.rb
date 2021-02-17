# frozen_string_literal: true

module BulkImports
  module Common
    module Transformers
      class UserReferenceTransformer
        DEFAULT_REFERENCE = 'user_id'

        def initialize(options = {})
          @reference = options[:reference] || DEFAULT_REFERENCE
        end

        def transform(context, data)
          user = find_user(context, data&.dig('user', 'public_email')) || context.current_user

          data
            .except('user')
            .merge(@reference => user.id)
        end

        private

        def find_user(context, email)
          return if email.blank?

          context.group.users.find_by_any_email(email, confirmed: true) # rubocop: disable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
