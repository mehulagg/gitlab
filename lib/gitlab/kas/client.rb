# frozen_string_literal: true

module Gitlab
  module Kas
    class Client
      TIMEOUT = 2.seconds

      STUB_CLASSES = {
        agent_tracker: Gitlab::Agent::AgentTracker::Rpc::AgentTracker::Stub
      }.freeze

      ConfigurationError = Class.new(StandardError)

      def initialize
        raise ConfigurationError, 'GitLab KAS is not enabled' unless Gitlab::Kas.enabled?
      end

      def get_connected_agents(project_id:)
        request = Gitlab::Agent::AgentTracker::Rpc::GetConnectedAgentsRequest.new(project_id: project_id)

        stub_for(:agent_tracker).get_connected_agents(request, metadata: metadata)
      end

      private

      def stub_for(service)
        @stubs ||= {}
        @stubs[service] ||= STUB_CLASSES.fetch(service).new(endpoint_url, credentials, timeout: TIMEOUT)
      end

      def endpoint_url
        Gitlab::Kas.internal_url.delete_prefix('grpc://')
      end

      def credentials
        if Rails.env.test? || Rails.env.development?
          :this_channel_is_insecure
        else
          GRPC::Core::ChannelCredentials.new
        end
      end

      def metadata
        { 'authorization' => "bearer #{token}" }
      end

      def token
        JSONWebToken::HMACToken.new(hmac_secret).encoded
      end

      def hmac_secret
        @hmac_secret ||= File.read(Gitlab::Kas.secret_path)
      end
    end
  end
end
