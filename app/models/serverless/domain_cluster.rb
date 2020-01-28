# frozen_string_literal: true

module Serverless
  class DomainCluster < ApplicationRecord
    self.table_name = 'serverless_domain_cluster'

    HEX_REGEXP = %r{\A\h+\z}.freeze

    belongs_to :pages_domain
    belongs_to :knative, class_name: 'Clusters::Applications::Knative', foreign_key: 'clusters_applications_knative_id'
    belongs_to :creator, class_name: 'User', optional: true

    validates :pages_domain, :knative, presence: true
    validates :uuid, presence: true, uniqueness: true, length: { is: Gitlab::Serverless::Domain::UUID_LENGTH },
              format: { with: HEX_REGEXP, message: 'only allows hex characters' }

    default_value_for(:uuid, allows_nil: false) { Gitlab::Serverless::Domain.generate_uuid }
  end
end
