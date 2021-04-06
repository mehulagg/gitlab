# frozen_string_literal: true

module Ci
  class Build < Ci::Processable
    class Environment
      include Gitlab::Utils::StrongMemoize

      attr_accessor :build

      delegate :options, :merge_request, :metadata, :environment,
               :simple_variables, :persisted?, :success?, :failed?, :deployment
               to: :build

      ##
      # Since Gitlab 11.5, deployments records started being created right after
      # `ci_builds` creation. We can look up a relevant `environment` through
      # `deployment` relation today.
      # (See more https://gitlab.com/gitlab-org/gitlab-foss/merge_requests/22380)
      #
      # Since Gitlab 12.9, we started persisting the expanded environment name to
      # avoid repeated variables expansion in `action: stop` builds as well.
      def persisted_environment
        return unless has_environment?

        strong_memoize(:persisted_environment) do
          # This code path has caused N+1s in the past, since environments are only indirectly
          # associated to builds and pipelines; see https://gitlab.com/gitlab-org/gitlab/-/issues/326445
          # We therefore batch-load them to prevent dormant N+1s until we found a proper solution.
          BatchLoader.for(expanded_environment_name).batch(key: project_id) do |names, loader, args|
            Environment.where(name: names, project: args[:key]).find_each do |environment|
              loader.call(environment.name, environment)
            end
          end
        end
      end

      def expanded_environment_name
        return unless has_environment?
  
        strong_memoize(:expanded_environment_name) do
          # We're using a persisted expanded environment name in order to avoid
          # variable expansion per request.
          if metadata&.expanded_environment_name.present?
            metadata.expanded_environment_name
          else
            ExpandVariables.expand(environment, -> { simple_variables })
          end
        end
      end

      def has_environment?
        environment.present?
      end
  
      def starts_environment?
        has_environment? && self.environment_action == 'start'
      end
  
      def stops_environment?
        has_environment? && self.environment_action == 'stop'
      end
  
      def environment_action
        self.options.fetch(:environment, {}).fetch(:action, 'start') if self.options
      end
  
      def environment_deployment_tier
        self.options.dig(:environment, :deployment_tier) if self.options
      end

      def on_stop
        options&.dig(:environment, :on_stop)
      end

      def persisted_environment_variables
        Gitlab::Ci::Variables::Collection.new.tap do |variables|
          break variables unless persisted? && persisted_environment.present?
  
          variables.concat(persisted_environment.predefined_variables)
  
          # Here we're passing unexpanded environment_url for runner to expand,
          # and we need to make sure that CI_ENVIRONMENT_NAME and
          # CI_ENVIRONMENT_SLUG so on are available for the URL be expanded.
          variables.append(key: 'CI_ENVIRONMENT_URL', value: environment_url) if environment_url
        end
      end

      # Virtual deployment status depending on the environment status.
      def deployment_status
        return unless starts_environment?

        if success?
          return successful_deployment_status
        elsif failed?
          return :failed
        end

        :creating
      end

      def expanded_kubernetes_namespace
        return unless has_environment?
  
        namespace = options.dig(:environment, :kubernetes, :namespace)
  
        if namespace.present?
          strong_memoize(:expanded_kubernetes_namespace) do
            ExpandVariables.expand(namespace, -> { simple_variables })
          end
        end
      end

      private

      def environment_url
        options&.dig(:environment, :url) || persisted_environment&.external_url
      end

      def successful_deployment_status
        if deployment&.last?
          :last
        else
          :out_of_date
        end
      end
    end
  end
end
