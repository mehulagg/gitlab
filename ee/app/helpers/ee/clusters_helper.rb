# frozen_string_literal: true

module EE
  module ClustersHelper
    extend ::Gitlab::Utils::Override

    override :cluster_list_tabs
    def cluster_list_tabs(clusterable)
      return super unless display_cluster_agents?(clusterable)

      [
        {
          id: 'agent-clusters',
          class: 'active',
          text: s_('ClusterIntegration|GitLab Agent managed clusters')
        },
        {
          id: 'certificate-clusters',
          class: '',
          text: s_('ClusterIntegration|Clusters connected with a certificate')
        }
      ]
    end

    override :js_cluster_agents_list
    def js_cluster_agents_list(clusterable)
      return unless display_cluster_agents?(clusterable)

      content_tag(
        :div,
        nil,
        id: 'js-cluster-agents-list',
        data: {
          default_branch_name: clusterable.repository&.root_ref,
          empty_state_image: image_path('illustrations/clusters_empty.svg'),
          project_path: clusterable.full_path
        }
      )
    end

    private

    def display_cluster_agents?(clusterable)
      clusterable.is_a?(Project) && clusterable.feature_available?(:cluster_agents)
    end
  end
end
