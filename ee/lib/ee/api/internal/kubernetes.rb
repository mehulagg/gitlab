# frozen_string_literal: true
module EE
  module API
    module Internal
      module Kubernetes
        extend ActiveSupport::Concern
        prepended do
          helpers do
            extend ::Gitlab::Utils::Override

            override :kubernetes_namespaces
            def kubernetes_namespaces(project)
              return {} unless project.feature_available?(:cilium_alerts)

              {
                namespaces: ::Clusters::KubernetesNamespaces::ListService.new(project: project).execute
              }
            end
          end
          namespace 'internal' do
            namespace 'kubernetes' do
              before { check_agent_token }

              namespace 'modules/cilium_alert' do
                desc 'POST network alerts' do
                  detail 'Creates network alert'
                end
                params do
                  requires :alert, type: Hash, desc: 'Alert details'
                end

                route_setting :authentication, cluster_agent_token_allowed: true
                post '/' do
                  project = agent.project

                  not_found! if project.nil?

                  forbidden! unless project.feature_available?(:cilium_alerts)

                  result = ::AlertManagement::NetworkAlertService.new(project, params[:alert]).execute

                  status result.http_status
                end
              end
            end
          end
        end
      end
    end
  end
end
