# frozen_string_literal: true
class Packages::ComposerPackagesFinder < Packages::GroupPackagesFinder
  attr_reader :current_user, :group

  def initialize(current_user, group = nil, params = {})
    @current_user = current_user
    @group = group
    @params = params
  end

  def execute
    if group
      packages_for_group_projects.composer.with_composer_metadata
    else
      packages_for_multiple_projects_matching_namespace
    end
  end

  private

  def projects_visible_to_current_user
    ::Project
        .public_or_visible_to_user(current_user, Gitlab::Access::REPORTER)
  end

  def packages_for_multiple_projects_matching_namespace
    packages = ::Packages::Package
                   .including_project_and_namespace
                   .composer
                   .with_composer_metadata
                   .for_projects(projects_visible_to_current_user)
                   .find_each

    packages_composer_matching_namespace(packages)
  end

  def packages_composer_matching_namespace(packages)
    packages.select do |package|
      package_namespace = package.name.match(Gitlab::Regex.composer_package_name_regex)[1]

      package.project.namespace.path == package_namespace
    end
  end
end
