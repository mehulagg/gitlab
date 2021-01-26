# frozen_string_literal: true

module EE
  module Groups
    module ImportExport
      module ImportService
        extend ::Gitlab::Utils::Override

        override :restorers
        def restorers
          (super << group_and_subgroup_wikis_repo_restorer).compact
        end

        def group_and_subgroup_wikis_repo_restorer
          return unless group.feature_available?(:group_wikis)

          ::Groups::ImportExport::GroupWikisRepoRestorer.new(group: group, shared: shared)
        end
      end
    end
  end
end
