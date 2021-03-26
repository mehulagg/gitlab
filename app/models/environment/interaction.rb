# frozen_string_literal: true

class Environment
  class Interaction < ApplicationRecord
    belongs_to :environment
    belongs_to :deployment, optional: true
    belongs_to :build, class_name: 'Ci::Build', optional: true
    belongs_to :user, optional: true

    enum interaction_source: {
      build: 0,
      user: 1
    }

    enum action_type: {
      start: 0,
      stop: 1,
      prepare: 2,
      change_canary_weight: 3
    }
  end
end
