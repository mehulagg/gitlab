# frozen_string_literal: true

module Gitlab
  module DataBuilder
    module Deployment
      extend self

      SAMPLE_DATA =
        {
          object_kind: 'deployment',
          status: :success,
          deployable_id: 17,
          deployable_url: 'test.gitlab.example.com',
          environment: 'test_environment',
          project: {
            id: 15,
            name: "gitlab",
            description: "",
            web_url: "http://test.example.com/gitlab/gitlab",
            avatar_url: "https://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=8://s.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=80",
            git_ssh_url: "git@test.example.com:gitlab/gitlab.git",
            git_http_url: "http://test.example.com/gitlab/gitlab.git",
            namespace: "gitlab",
            visibility_level: 0,
            path_with_namespace: "gitlab/gitlab",
            default_branch: "master"
          },
          ref: 'refs/heads/master',
          short_sha: 'aaaaaa',
          user: {
            name: 'Test User',
            username: 'testuser',
            avatar_url: 'https://secure.gravatar.com/avatar/c4ac5c1a595fe25bad7ddb2eb2d7c2f4?s=80&d=identicon',
            email: 'testuser@example.com'
          },
          user_url: 'https://gitlab.example.com/test_user',
          commit_url: 'https://gitlab.example.com/user/project/-/tree/aaaaaa',
          commit_title: 'my favorite commit'
        }.freeze

      def build(deployment)
        # Deployments will not have a deployable when created using the API.
        deployable_url =
          if deployment.deployable
            Gitlab::UrlBuilder.build(deployment.deployable)
          end

        {
          object_kind: 'deployment',
          status: deployment.status,
          deployable_id: deployment.deployable_id,
          deployable_url: deployable_url,
          environment: deployment.environment.name,
          project: deployment.project.hook_attrs,
          ref: deployment.ref,
          short_sha: deployment.short_sha,
          user: deployment.user.hook_attrs,
          user_url: Gitlab::UrlBuilder.build(deployment.user),
          commit_url: Gitlab::UrlBuilder.build(deployment.commit),
          commit_title: deployment.commit.title
        }
      end

      def build_sample(ref = nil)
        data = sample_data.dup
        data[:ref] = ref unless ref.nil?
        data
      end

      def sample_data
        SAMPLE_DATA
      end
    end
  end
end
