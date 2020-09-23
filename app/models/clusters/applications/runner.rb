# frozen_string_literal: true

module Clusters
  module Applications
    class Runner < ApplicationRecord
      VERSION = '0.21.0'

      self.table_name = 'clusters_applications_runners'

      include ::Clusters::Concerns::ApplicationCore
      include ::Clusters::Concerns::ApplicationStatus
      include ::Clusters::Concerns::ApplicationVersion
      include ::Clusters::Concerns::ApplicationData

      belongs_to :runner, class_name: 'Ci::Runner', foreign_key: :runner_id
      delegate :project, :group, to: :cluster

      default_value_for :version, VERSION

      def chart
        "#{name}/gitlab-runner"
      end

      def repository
        'https://charts.gitlab.io'
      end

      def values
        content_values.to_yaml
      end

      def install_command
        Gitlab::Kubernetes::Helm::InstallCommand.new(
          name: name,
          version: VERSION,
          rbac: cluster.platform_kubernetes_rbac?,
          chart: chart,
          files: files,
          repository: repository,
          preinstall: pre_install_script
        )
      end

      def prepare_uninstall
        runner&.update!(active: false)
      end

      def post_uninstall
        runner.destroy!
      end

      private

      def ensure_runner
        runner || create_and_assign_runner
      end

      def create_and_assign_runner
        transaction do
          Ci::Runner.create!(runner_create_params).tap do |runner|
            update!(runner_id: runner.id)
          end
        end
      end

      def runner_create_params
        attributes = {
          name: 'kubernetes-cluster',
          runner_type: cluster.cluster_type,
          tag_list: %w[kubernetes cluster]
        }

        if cluster.group_type?
          attributes[:groups] = [group]
        elsif cluster.project_type?
          attributes[:projects] = [project]
        end

        attributes
      end

      def gitlab_url
        Gitlab::Routing.url_helpers.root_url(only_path: false)
      end

      def specification
        {
          "gitlabUrl" => gitlab_url,
          "runnerToken" => ensure_runner.token,
          "runners" => { "privileged" => privileged },
          "preEntrypointScript" => pre_entrypoint_script
        }
      end

      def pre_entrypoint_script
        return unless registry_ca.present?

        <<~BASH
          #!/bin/bash
          cat << EOF >> /home/gitlab-runner/.gitlab-runner/config.toml
          [[runners.kubernetes.volumes.config_map]]
            name = "gitlab-registry-ca"
            mount_path = "/etc/docker/certs.d/#{Gitlab.config.registry.host_port}"
            [runners.kubernetes.volumes.config_map.items]
              "ca.crt" = "ca.crt"
          EOF
        BASH
      end

      def pre_install_script
        return unless registry_ca.present?

        configmap = <<~YAML
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: gitlab-registry-ca
            namespace: gitlab-managed-apps
          data:
            ca.crt: |
          #{registry_ca.indent(4)}
        YAML

        [
          "echo #{configmap.shellescape} > /tmp/runner-ca-configmap.yaml",
          "kubectl --namespace #{Gitlab::Kubernetes::Helm::NAMESPACE} apply -f /tmp/runner-ca-configmap.yaml"
        ]
      end

      def registry_ca
        @registry_ca ||= File.open(Gitlab.config.registry.ca, &:read)
      end

      def content_values
        YAML.load_file(chart_values_file).deep_merge!(specification)
      end
    end
  end
end
