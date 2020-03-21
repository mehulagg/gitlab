# frozen_string_literal: true

module Ci
  class TriggerRequest < ApplicationRecord
    extend Gitlab::Ci::Model
    include IgnorableColumns

    ignore_column :commit_id, remove_after: '2020-04-22', remove_with: '13.0'

    belongs_to :trigger
    belongs_to :pipeline, foreign_key: :pipeline_id
    has_many :builds

    delegate :short_token, to: :trigger, prefix: true, allow_nil: true

    # We switched to Ci::PipelineVariable from Ci::TriggerRequest.variables.
    # Ci::TriggerRequest doesn't save variables anymore.
    validates :variables, absence: true

    serialize :variables # rubocop:disable Cop/ActiveRecordSerialize

    def user_variables
      return [] unless variables

      variables.map do |key, value|
        { key: key, value: value, public: false }
      end
    end
  end
end
