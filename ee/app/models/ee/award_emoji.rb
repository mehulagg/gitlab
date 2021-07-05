# frozen_string_literal: true

module EE
  module AwardEmoji
    extend ActiveSupport::Concern

    prepended do
      UPDATE_ELASTIC_ASSOCIATIONS_FOR = [::Issue].freeze

      after_commit :update_elastic_associations, on: [:create, :destroy]

      def update_elastic_associations
        return unless UPDATE_ELASTIC_ASSOCIATIONS_FOR.any? { |model| awardable.is_a?(model) }
        return unless awardable.maintaining_elasticsearch?

        awardable.maintain_elasticsearch_update
      end
    end
  end
end
