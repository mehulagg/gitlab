# frozen_string_literal: true

module EE
  module API
    module Helpers
      module SearchHelpers
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :global_search_scopes
          def global_search_scopes
            ['wiki_blobs', 'blobs', 'commits', 'notes', *super]
          end

          override :group_search_scopes
          def group_search_scopes
            ['wiki_blobs', 'blobs', 'commits', 'notes', *super]
          end
        end
      end
    end
  end
end
