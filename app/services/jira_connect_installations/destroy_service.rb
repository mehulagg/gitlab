# frozen_string_literal: true

module JiraConnectInstallations
  class DestroyService
    def initialize(installation, auth_header)
      @installation = installation
      @auth_header = auth_header
    end

    def execute
      if @installation.instance_url
        JiraConnect::ForwardEventWorker.perform_async(@installation.id, @auth_header)
        return true
      end

      @installation.destroy
    end
  end
end
