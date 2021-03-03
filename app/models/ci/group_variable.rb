# frozen_string_literal: true

module Ci
  class GroupVariable < ApplicationRecord
    extend Gitlab::Ci::Model
    include Ci::HasVariable
    include Presentable
    include Ci::Maskable
    prepend HasEnvironmentScope

    belongs_to :group, class_name: "::Group"

    alias_attribute :secret_value, :value

    validates :key, uniqueness: {
      scope: [:group_id, :environment_scope],
      message: "(%{value}) has already been taken"
    }

    scope :unprotected, -> { where(protected: false) }
  end
end
