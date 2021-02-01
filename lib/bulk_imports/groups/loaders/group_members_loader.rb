# frozen_string_literal: true

module BulkImports
  module Groups
    module Loaders
      class GroupMembersLoader
        NotAllowedError = Class.new(StandardError)

        def initialize(*); end

        def load(context, data)
          return unless data
          raise NotAllowedError unless authorized?

          context.entity.group.add_user(
            data['user'],
            data['access_level'],
            expires_at: data['expires_at'],
            current_user: context.current_user
          )
        end

        private

        def authorized?(context)
          context.current_user.admin?
        end
      end
    end
  end
end
