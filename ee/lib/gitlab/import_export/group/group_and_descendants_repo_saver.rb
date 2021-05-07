# frozen_string_literal: true

# Given a group, this class can export the
# wiki repositories for the main group and all its
# descendants.
#
# If we want to export more group repositories in the future
# we should extend this class.
module Gitlab
  module ImportExport
    module Group
      class GroupAndDescendantsRepoSaver
        attr_reader :group, :shared

        def initialize(group:, shared:)
          @group = group
          @shared = shared
        end

        def save
          group.self_and_descendants.find_each.all? do |subgroup|
            save_wiki(subgroup)
          end
        end

        private

        def save_wiki(group)
          ::Gitlab::ImportExport::WikiRepoSaver.new(
            exportable: group,
            shared: shared).save
        end
      end
    end
  end
end
