# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module Summary
        module Group
          class DeploymentFrequency < Group::Base
            include Gitlab::CycleAnalytics::GroupProjectsProvider
            include Gitlab::CycleAnalytics::SummaryHelper

            def initialize(deployments:, group:, options:)
              @deployments = deployments

              super(group: group, options: options)
            end

            def title
              _('Deployment Frequency')
            end

            def value
              @value ||=
                frequency(@deployments, options[:from], options[:to] || Time.current)
            end

            def unit
              _('per day')
            end
          end
        end
      end
    end
  end
end
