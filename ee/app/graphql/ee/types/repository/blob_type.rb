# frozen_string_literal: true

module EE
  module Types
    module Repository
      module BlobType
        extend ActiveSupport::Concern

        # FIXME: these need support based on the existing path locks.
        prepended do
          field :can_lock, GraphQL::BOOLEAN_TYPE, null: true,
                description: 'Whether the current user is able to mark this file as locked.'

          field :is_locked, GraphQL::BOOLEAN_TYPE, null: true,
                description: 'Whether this file is currently locked.'

          field :lock_link, GraphQL::STRING_TYPE, null: true,
                description: "Path to the endpoint used to toggle this file's lock status."
        end
      end
    end
  end
end
