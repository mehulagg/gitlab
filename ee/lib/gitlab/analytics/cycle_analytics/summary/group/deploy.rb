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
              @deployments_count ||= if Feature.enabled?(:query_deploymenys_via_finished_at_in_vsa)
                                       deployments = DeploymentsFinder
                                         .new(group: group, finished_after: options[:from], finished_before: options[:to], status: :success)
                                         .execute

                                       deployments = deployments.where(project_id: options[:projects]) if options[:projects].present?
                                       deployments.count
                                     else
                                       deployments = Deployment.joins(:project).merge(Project.inside_path(group.full_path))
                                       deployments = deployments.where(projects: { id: options[:projects] }) if options[:projects].present?
                                       deployments = deployments.where("deployments.created_at > ?", options[:from])
                                       deployments = deployments.where("deployments.created_at < ?", options[:to]) if options[:to]
                                       deployments.success.count
                                     end
            end
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
