# frozen_string_literal: true

module EE
  module Gitlab
    module GlRepository
      module RepoType
        extend ::Gitlab::Utils::Override

        # TODO we have a problem here. We're adding the CanMoveRepositoryStorage concern
        # to the Group model. Nevertheless, when we call reference_counter and we get the
        # identifier, we pass `self`, which is not a GroupWiki but a Group. Therefore
        # it returns wiki-1 instead of group-1-wiki
        override :identifier_for_container
        def identifier_for_container(container)
          if container.is_a?(GroupWiki) || container.is_a?(Group)
            "group-#{container.id}-#{name}"
          else
            super
          end
        end
      end
    end
  end
end
