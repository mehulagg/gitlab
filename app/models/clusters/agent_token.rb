# frozen_string_literal: true

module Clusters
  class AgentToken < ApplicationRecord
    include TokenAuthenticatable
    add_authentication_token_field :token, encrypted: :required

    self.table_name = 'cluster_agent_tokens'

    belongs_to :agent, class_name: 'Clusters::Agent'

    before_save :ensure_token
  end
end
