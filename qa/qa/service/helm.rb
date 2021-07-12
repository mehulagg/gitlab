# frozen_string_literal: true

module QA
  module Service
    module Helm
      include Service::Shellout
      module_function

      HELM_VERSION = 3
      GITLAB_CHARTS = 'https://charts.gitlab.io'

      def install_gitlab_chart(chart:, namespace: 'kube-system', opts: '')
        validate_dependencies
        shell "helm repo add gitlab #{GITLAB_CHARTS}"
        shell "helm install --namespace #{namespace} #{chart} #{opts} gitlab/#{chart}"
        shell 'helm repo rm gitlab'
      end

      def validate_dependencies
        find_executable('helm') || raise("You must first install `helm` executable to run these tests.")
        begin
          shell("helm version --short | grep -o 'v#{HELM_VERSION}\.'")
        rescue Shellout::CommandError
          raise("The version of Helm installed must be #{HELM_VERSION}.")
        end
      end
    end
  end
end
