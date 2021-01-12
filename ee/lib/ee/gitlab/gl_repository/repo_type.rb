# frozen_string_literal: true

module EE
  module Gitlab
    module GlRepository
      module RepoType
        extend ::Gitlab::Utils::Override

        override :identifier_for_container
        def identifier_for_container(container)
          if container.is_a?(GroupWiki) || (wiki? && container.is_a?(Group))
            "group-#{container.id}-#{name}"
          else
            super
          end
        end
      end
    end
  end
end
