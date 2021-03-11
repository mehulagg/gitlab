# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        module Formatters
          class DependencyList
            def initialize(project, sha)
              @commit_path = ::Gitlab::Routing.url_helpers.project_blob_path(project, sha)
              @project = project
            end

            def format(dependency, package_manager, file_path, vulnerabilities = [])
              {
                name: dependency['package']['name'],
                iid: dependency['iid'],
                packager: packager(package_manager),
                package_manager: package_manager,
                location: formatted_location(dependency, file_path),
                version:  dependency['version'],
                vulnerabilities: formatted_vulnerabilities(vulnerabilities),
                licenses: []
              }
            end

            private

            attr_reader :commit_path, :project

            def blob_path(file_path)
              "#{commit_path}/#{file_path}"
            end

            def packager(package_manager)
              case package_manager
              when 'bundler'
                'Ruby (Bundler)'
              when 'yarn'
                'JavaScript (Yarn)'
              when 'npm'
                'JavaScript (npm)'
              when 'pip'
                'Python (pip)'
              when 'maven'
                'Java (Maven)'
              when 'composer'
                'PHP (Composer)'
              when 'conan'
                'C/C++ (Conan)'
              else
                package_manager
              end
            end

            def formatted_location(dependency, file_path)
              base_location = {
                blob_path: blob_path(file_path),
                path:      file_path
              }

              return base_location unless dependency['iid']

              base_location.merge({
                                    ancestors: formatted_dependency_path(dependency['dependency_path']),
                                    top_level: !!dependency['direct']
                                  })
            end

            def formatted_dependency_path(dependency_path)
              return unless dependency_path

              dependency_path.map { |path| path.with_indifferent_access }
            end

            # we know that Parsers::Security::DependencyList parses one vulnerability at a time
            # however, to keep interface compability with rest of the code and have MVC we return array
            # even tough we know that array's size will be 1
            def formatted_vulnerabilities(vulnerabilities)
              return [] if vulnerabilities.blank?

              if Feature.enabled?(:standalone_vuln_dependency_list, project)
                [{ id: vulnerabilities.id, url: vulnerability_url(vulnerabilities.id) }]
              else
                [{ name: vulnerabilities['message'], severity: vulnerabilities['severity'].downcase }]
              end
            end

            # Dependency List report is generated by dependency_scanning job.
            # This is how the location is generated there
            # https://gitlab.com/gitlab-org/security-products/analyzers/common/blob/a0a5074c49f34332aa3948cd9d6dc2c054cdf3a7/issue/issue.go#L169
            def location(dependency, file_path)
              {
                'file' => file_path,
                'dependency' => {
                  'package' => {
                    'name' => dependency['package']['name']
                  },
                  'version' => dependency['version']
                }
              }
            end

            def vulnerability_url(id)
              ::Gitlab::Routing.url_helpers.project_security_vulnerability_url(project, id)
            end
          end
        end
      end
    end
  end
end
