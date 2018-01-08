module EE
  module DeploymentPlatform
    def deployment_platform(environment: nil)
      return super unless environment && feature_available?(:multiple_clusters)

      @deployment_platform ||= # rubocop:disable Gitlab/ModuleWithInstanceVariables
        clusters.enabled.on_environment(environment.name)
          .last&.platform_kubernetes

      super # Wildcard or KubernetesService
    end
  end
end
