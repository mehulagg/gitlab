# frozen_string_literal: true

module Geo
  class RepositoryUpdatedEvent < ApplicationRecord
    extend ::Gitlab::Utils::Override
    include Geo::Model
    include Geo::Eventable

    REPOSITORY = 0
    WIKI       = 1
    DESIGN     = 2

    REPOSITORY_TYPE_MAP = {
      ::Gitlab::GlRepository::PROJECT => REPOSITORY,
      ::Gitlab::GlRepository::WIKI => WIKI,
      ::Gitlab::GlRepository::DESIGN => DESIGN
    }.freeze

    belongs_to :project

    enum source: { repository: REPOSITORY, wiki: WIKI, design: DESIGN }

    validates :project, presence: true

    def self.source_for(repository)
      REPOSITORY_TYPE_MAP[repository.repo_type]
    end

    override :consumer_klass_name
    def consumer_klass_name
      if design?
        ::Gitlab::Geo::LogCursor::Events::DesignRepositoryUpdatedEvent.name.demodulize
      else
        super
      end
    end
  end
end
