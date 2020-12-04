# frozen_string_literal: true

module API
  module Entities
    class SnippetRepositoryStorageMove < BasicRepositoryStorageMove
      expose :container, as: :snippet, using: Entities::BasicSnippet
    end
  end
end
