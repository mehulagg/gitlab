# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class IssuableConnectionType < GraphQL::Types::Relay::BaseConnection
    field :counts, Types::IssuableCountType, null: false,
          description: 'Total count of collection'

    def counts
      counts = Hash.new(0)
      # rubocop: disable CodeReuse/ActiveRecord
      relation = object.items

      if relation.is_a?(ActiveRecord::Relation)
        issuable_model.id_in(relation.select(:id)).group(:state_id).count.each do |key, value|
          counts[count_key(key)] = value
        end
      elsif relation.is_a?(Array)
        relation.group_by{|issuable| issuable.state }.map{|state, issuables| {state => issuables.count} }
      end
      # rubocop: enable CodeReuse/ActiveRecord

      counts[:all] = counts.values.sum

      counts.with_indifferent_access
    end

    private

    def count_key(value)
      issuable_model.available_states.key(value)
    end

    def issuable_model
      raise NotImplementedError
    end
  end
end
