# frozen_string_literal: true

module Vault
  class Setting < ApplicationRecord
    include NullifyIfBlank

    self.table_name = 'vault_settings'

    belongs_to :project, inverse_of: :vault_setting, required: true

    validates :server_url, length: 1..2047, public_url: true
    validates :auth_role, length: 1..255, allow_nil: true
    validates :auth_path, length: 1..255, allow_nil: true

    nullify_if_blank :auth_role, :auth_path
  end
end
