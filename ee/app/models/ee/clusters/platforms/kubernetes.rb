# frozen_string_literal: true

module EE
  module Clusters
    module Platforms
      module Kubernetes
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :calculate_reactive_cache_for
        def calculate_reactive_cache_for(environment)
          result = super

          if result
            deployments = read_deployments(environment.deployment_namespace)

            # extract_relevant_deployment_data avoids uploading all the deployment info into ReactiveCaching
            result[:deployments] = extract_relevant_deployment_data(deployments)
          end

          result
        end

        def rollout_status(environment, data)
          project = environment.project

          deployments = filter_by_project_environment(data[:deployments], project.full_path_slug, environment.slug)
          pods = filter_by_project_environment(data[:pods], project.full_path_slug, environment.slug)
          legacy_deployments = filter_by_legacy_label(data[:deployments], project.full_path_slug, environment.slug)

          ::Gitlab::Kubernetes::RolloutStatus.from_deployments(*deployments, pods: pods, legacy_deployments: legacy_deployments)
        end

        private

        def read_deployments(namespace)
          kubeclient.get_deployments(namespace: namespace).as_json
        rescue Kubeclient::ResourceNotFoundError
          []
        end

        def extract_relevant_deployment_data(deployments)
          deployments.map do |deployment|
            {
              'metadata' => deployment.fetch('metadata', {}).slice('name', 'generation', 'labels', 'annotations'),
              'spec' => deployment.fetch('spec', {}).slice('replicas'),
              'status' => deployment.fetch('status', {}).slice('observedGeneration')
            }
          end
        end
      end
    end
  end
end
