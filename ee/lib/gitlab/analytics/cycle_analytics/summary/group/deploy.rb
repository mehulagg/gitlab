# frozen_string_literal: true

module Gitlab
  module Analytics
    module CycleAnalytics
      module Summary
        module Group
          class Deploy < Group::Base
            include Gitlab::CycleAnalytics::GroupProjectsProvider

            def title
              n_('Deploy', 'Deploys', value.to_i)
            end

            def value
              @value ||= ::Gitlab::CycleAnalytics::Summary::Value::PrettyNumeric.new(deployments_count)
            end

            private

            # rubocop: disable CodeReuse/ActiveRecord
            def deployments_count
              @deployments_count ||= begin
                deployments = DeploymentsFinder
                  .new(group: group, finished_after: options[:from], finished_before: options[:to], status: :success)
                  .execute

                deployments = deployments.where(project_id: options[:projects]) if options[:projects].present?
                deployments.count
              end
            end
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
