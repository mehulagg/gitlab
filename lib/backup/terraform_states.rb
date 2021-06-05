# frozen_string_literal: true

module Backup
  class TerraformStates < Backup::Files
    attr_reader :progress

    def initialize(progress)
      @progress = progress

      super('terraform_state', Settings.terraform_state.storage_path)
    end
  end
end
