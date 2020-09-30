# frozen_string_literal: true

module Environments
  class CanaryTrack
    include ActiveModel::Model

    attr_accessor :environment

    def exists?
      return false unless environment.deployment_platform

      
    end

    def ingress_exists?

    end
  end
end
