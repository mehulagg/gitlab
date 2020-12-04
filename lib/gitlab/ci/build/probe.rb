# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Probe
        attr_reader :tcp, :http_get, :exec, :retries, :initial_delay, :period, :timeout

        def initialize(probe)
          @retries = probe[:retries]
          @initial_delay = probe[:initial_delay]
          @period = probe[:period]
          @timeout = probe[:timeout]

          if probe.has_key?(:tcp)
            @tcp = ::Gitlab::Ci::Build::Probe::Tcp.new(probe[:tcp])
          end

          if probe.has_key?(:http_get)
            @http_get = ::Gitlab::Ci::Build::Probe::HttpGet.new(probe[:http_get])
          end

          if probe.has_key?(:exec)
            @exec = ::Gitlab::Ci::Build::Probe::Exec.new(probe[:exec])
          end
        end

        def valid?
          @tcp.present? || @http_get.present? || @exec.present?
        end
      end
    end
  end
end
