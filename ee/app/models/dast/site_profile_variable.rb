# frozen_string_literal: true

module Dast
  class SiteProfileVariable < ApplicationRecord
    self.table_name = 'dast_site_profile_variables'

    include Ci::NewHasVariable
    include Ci::Maskable

    belongs_to :dast_site_profile
    delegate :project, to: :dast_site_profile, allow_nil: false

    alias_attribute :secret_value, :value

    attribute :masked, default: true
    attribute :variable_type, default: 'env_var'

    validates :masked, inclusion: { in: [true] }
    validates :variable_type, inclusion: { in: ['env_var'] }

    validates :key, uniqueness: {  scope: :dast_site_profile_id, message: "(%{value}) has already been taken" }

    def raw_value=(new_value)
      self.value = Base64.strict_encode64(new_value)
    end
  end
end
