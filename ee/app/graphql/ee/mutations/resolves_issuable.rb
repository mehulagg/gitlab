# frozen_string_literal: true

module EE
  module Mutations
    module ResolvesIssuable
      include ::Mutations::ResolvesGroup
      extend ::Gitlab::Utils::Override

      private

      def issuable_finder(type, args)
        return EpicsFinder.new(current_user, args) if type == :epic

        super
      end

      override :resolve_issuable_parent
      def resolve_issuable_parent(type, parent_path)
        return super unless type == :epic

        resolve_group(full_path: parent_path)
      end
    end
  end
end
