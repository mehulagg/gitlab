# frozen_string_literal: true

module Gitlab
  module Graphql
    module Loaders
      class OncallParticipantLoader
        attr_reader :participant_id

        def initialize(participant_id)
          @participant_id = participant_id
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def find
          BatchLoader::GraphQL.for(participant_id.to_i).batch do |ids, loader|
            results = ::IncidentManagement::OncallParticipant.includes(:user).id_in(ids)

            results.each { |participant| loader.call(participant.id, participant) }
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord
      end
    end
  end
end
