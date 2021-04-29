# frozen_string_literal: true

module Gitlab
  module Email
    module Message
      module InProductMarketing
        class Create < Base
          def subject_line
            [
              s_('InProductMarketing|Create a project in GitLab in 5 minutes'),
              s_('InProductMarketing|Import your project and code from GitHub, Bitbucket and others'),
              s_('InProductMarketing|Understand repository mirroring')
            ][series]
          end

          def tagline
            [
              s_('InProductMarketing|Get started today'),
              s_('InProductMarketing|Get our import guides'),
              s_('InProductMarketing|Need an alternative to importing?')
            ][series]
          end

          def title
            [
              s_('InProductMarketing|Take your first steps with GitLab'),
              s_('InProductMarketing|Start by importing your projects'),
              s_('InProductMarketing|How (and why) mirroring makes sense')
            ][series]
          end

          def subtitle
            [
              s_('InProductMarketing|Dig in and create a project and a repo'),
              s_("InProductMarketing|Here's what you need to know"),
              s_('InProductMarketing|Try it out')
            ][series]
          end

          def body_line1
            [
              s_("InProductMarketing|To understand and get the most out of GitLab, start at the beginning and %{project_link}. In GitLab, repositories are part of a project, so after you've created your project you can go ahead and %{repo_link}.") % { project_link: project_link(format), repo_link: repo_link(format) },
              s_("InProductMarketing|Making the switch? It's easier than you think to import your projects into GitLab. Move %{github_link}, or import something %{bitbucket_link}.") % { github_link: github_link(format), bitbucket_link: bitbucket_link(format) },
              s_("InProductMarketing|Sometimes you're not ready to make a full transition to a new tool. If you're not ready to fully commit, %{mirroring_link} gives you a safe way to try out GitLab in parallel with your current tool.") % { mirroring_link: mirroring_link(format) }
            ][series]
          end

          def body_line2
            [
              s_("InProductMarketing|That's all it takes to get going with GitLab, but if you're new to working with Git, check out our %{basics_link} for helpful tips and tricks for getting started.") % { basics_link: basics_link(format) },
              s_("InProductMarketing|Have a different instance you'd like to import? Here's our %{import_link}.") % { import_link: import_link(format) },
              s_("InProductMarketing|It's also possible to simply %{external_repo_link} in order to take advantage of GitLab's CI/CD.") % { external_repo_link: external_repo_link(format) }
            ][series]
          end

          def cta_text
            [
              s_('InProductMarketing|Create your first project!'),
              s_('InProductMarketing|Master the art of importing!'),
              s_('InProductMarketing|Understand your project options')
            ][series]
          end

          private

          def project_link(format)
            link(s_('InProductMarketing|create a project'), help_page_url('gitlab-basics/create-project'), format)
          end

          def repo_link(format)
            link(s_('InProductMarketing|set up a repo'), help_page_url('user/project/repository/index', anchor: 'create-a-repository'), format)
          end

          def github_link(format)
            link(s_('InProductMarketing|GitHub Enterprise projects to GitLab'), help_page_url('integration/github'), format)
          end

          def bitbucket_link(format)
            link(s_('InProductMarketing|from Bitbucket'), help_page_url('user/project/import/bitbucket_server'), format)
          end

          def mirroring_link(format)
            link(s_('InProductMarketing|repository mirroring'), help_page_url('user/project/repository/repository_mirroring'), format)
          end

          def basics_link(format)
            link(s_('InProductMarketing|Git basics'), help_page_url('gitlab-basics/README'), format)
          end

          def import_link(format)
            link(s_('InProductMarketing|comprehensive guide'), help_page_url('user/project/import/index'), format)
          end

          def external_repo_link(format)
            link(s_('InProductMarketing|connect an external repository'), new_project_url(anchor: 'cicd_for_external_repo'), format)
          end
        end
      end
    end
  end
end
