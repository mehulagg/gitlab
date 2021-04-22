# frozen_string_literal: true

module Gitlab
  module ImportExport
    extend self

    # For every version update the version history in these docs must be kept up to date:
    # - development/import_export.md
    # - user/project/settings/import_export.md
    VERSION = '0.2.4'
    FILENAME_LIMIT = 50

    def export_path(relative_path:)
      File.join(storage_path, relative_path)
    end

    def storage_path
      File.join(Settings.shared['path'], 'tmp/gitlab_exports')
    end

    def import_upload_path(filename:)
      File.join(storage_path, 'uploads', filename)
    end

    def project_filename
      "project.json"
    end

    def project_bundle_filename
      "project.bundle"
    end

    def lfs_objects_filename
      "lfs-objects.json"
    end

    def lfs_objects_storage
      "lfs-objects"
    end

    def wiki_repo_bundle_filename
      "project.wiki.bundle"
    end

    def design_repo_bundle_filename
      'project.design.bundle'
    end

    def snippet_repo_bundle_dir
      'snippets'
    end

    def snippets_repo_bundle_path(absolute_path)
      File.join(absolute_path, ::Gitlab::ImportExport.snippet_repo_bundle_dir)
    end

    def snippet_repo_bundle_filename_for(snippet)
      "#{snippet.hexdigest}.bundle"
    end

    def config_file
      Rails.root.join('lib/gitlab/import_export/project/import_export.yml')
    end

    def version_filename
      'VERSION'
    end

    def gitlab_version_filename
      'GITLAB_VERSION'
    end

    def gitlab_revision_filename
      'GITLAB_REVISION'
    end

    def export_filename(exportable:)
      basename = "#{Time.now.strftime('%Y-%m-%d_%H-%M-%3N')}_#{exportable.full_path.tr('/', '_')}"

      "#{basename[0..FILENAME_LIMIT]}_export.tar.gz"
    end

    def version
      VERSION
    end

    def reset_tokens?
      true
    end

    def group_filename
      'group.json'
    end

    def legacy_group_config_file
      Rails.root.join('lib/gitlab/import_export/group/legacy_import_export.yml')
    end

    def group_config_file
      Rails.root.join('lib/gitlab/import_export/group/import_export.yml')
    end

    def top_level_relations(exportable_class)
      config = Gitlab::ImportExport::Config.new(config: import_export_yaml(exportable_class)).to_h

      config.dig(:tree, exportable_class.to_s.downcase.to_sym).keys.map(&:to_s)
    end

    def import_export_yaml(exportable_class)
      case exportable_class
      when ::Project.name
        config_file
      when ::Group.name
        group_config_file
      else
        raise Gitlab::ImportExport::Error.unsupported_object_type_error
      end
    end
  end
end

Gitlab::ImportExport.prepend_if_ee('EE::Gitlab::ImportExport')

# The methods in `Gitlab::ImportExport::GroupHelper` should be available as both
# instance and class methods.
Gitlab::ImportExport.extend_if_ee('Gitlab::ImportExport::GroupHelper')
