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

            ingresses = if ::Feature.enabled?(:canary_ingress_weight_control, environment.project, default_enabled: true)
                          read_ingresses(environment.deployment_namespace)
                        else
                          []
                        end

            # extract_relevant_deployment_data avoids uploading all the deployment info into ReactiveCaching
            result[:deployments] = extract_relevant_deployment_data(deployments)
            result[:ingresses] = extract_relevant_ingress_data(ingresses)
          end

          result
        end

        def rollout_status(environment, data)
          project = environment.project

          deployments = filter_by_project_environment(data[:deployments], project.full_path_slug, environment.slug)
          pods = filter_by_project_environment(data[:pods], project.full_path_slug, environment.slug)
          ingresses = data[:ingresses].presence || []

          ::Gitlab::Kubernetes::RolloutStatus.from_deployments(*deployments, pods_attrs: pods, ingresses: ingresses)
        end

        def ingresses(namespace)
          ingresses = read_ingresses(namespace)
          ingresses.map { |ingress| ::Gitlab::Kubernetes::Ingress.new(ingress) }
        end

        def patch_ingress(namespace, ingress, data)
          kubeclient.patch_ingress(ingress.name, data, namespace)
        end

        private

        def read_deployments(namespace)
          kubeclient.get_deployments(namespace: namespace).as_json
        rescue Kubeclient::ResourceNotFoundError
          []
        end

        def read_ingresses(namespace)
          kubeclient.get_ingresses(namespace: namespace).as_json
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

        def extract_relevant_ingress_data(ingresses)
          ingresses.map do |ingress|
            {
              'metadata' => ingress.fetch('metadata', {}).slice('name', 'labels', 'annotations')
            }
          end
        end
      end
    end
  end
end
