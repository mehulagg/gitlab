# frozen_string_literal: true

module DesignManagement
  # Copies designs, version history, and annotations from one issue to another.
  # It avoids downloading the files themselves to improve memory performance.
  #
  # Todo perhaps a feature test to prove that this works?
  class CopyDesignsService < DesignService
    def initialize(project, user, params = {})
      super

      @to_issue = params.fetch(:to_issue)
      @to_project = @to_issue.project
      @to_repository = @to_project.design_repository

      @designs = DesignManagement::Design.unscoped.where(issue: issue).order(:id).to_a
      @versions = DesignManagement::Version.unscoped.where(issue: issue).order(:id).to_a
      @blobs = fetch_blobs

      @sha_attribute = Gitlab::Database::ShaAttribute.new
    end

    def execute
      return error('Forbidden!') unless can_copy_designs?
      return if designs.empty?

      ActiveRecord::Base.transaction(requires_new: true) do
        new_design_ids = copy_designs!
        new_version_ids = copy_versions!
        copy_actions!(new_design_ids, new_version_ids)
        copy_notes!(new_design_ids)
        link_lfs_files!
        create_commits!(new_version_ids) # Todo ask someone from Gitaly perhaps what the rollback scenario for this could be? Or do we not care really.
        # I get
        # Gitlab::Git::Index::IndexError: A file with this name already exists
        # from /Users/luke/Sites/gdk-ee/gitlab/lib/gitlab/gitaly_client/operation_service.rb:343:in `user_commit_files'
        #
        # Repository#revert can revert each commit
        # Do we have a bulk revert?
      end

      success
    end

    private

    attr_reader :to_project, :to_issue, :to_repository, :designs, :versions,
                :blobs, :sha_attribute

    # User has permission to copy designs if they can move/copy the issue.
    # This allows a user to execute this service, even if they have no
    # permissions to modify designs themselves.
    def can_copy_designs?
      issue.can_move?(current_user, to_issue.project)
    end

    def copy_designs!
      design_attributes = attributes_config[:design_attributes]

      new_rows = designs.map do |design|
        design.attributes.slice(*design_attributes).merge(
          issue_id: to_issue.id,
          project_id: to_project.id
        )
      end

      ::Gitlab::Database.bulk_insert(
        DesignManagement::Design.table_name,
        new_rows,
        return_ids: true
      )
    end

    def copy_versions!
      version_attributes = attributes_config[:version_attributes]

      new_rows = versions.map do |version|
        version.attributes.slice(*version_attributes).merge(
          issue_id: to_issue.id,
          sha: sha_attribute.serialize(version.sha)
        )
      end

      ::Gitlab::Database.bulk_insert(
        DesignManagement::Version.table_name,
        new_rows,
        return_ids: true
      )
    end

    def copy_actions!(new_design_ids, new_version_ids)
      # <Old design id> => <New design id>
      design_id_map = new_design_ids.each_with_index.each_with_object({}) do |design_id_and_index, hash|
        design_id, i = design_id_and_index
        hash[designs[i].id] = design_id
      end

      # <Old version id> => <New version id>
      version_id_map = new_version_ids.each_with_index.each_with_object({}) do |version_id_and_index, hash|
        version_id, i = version_id_and_index
        hash[versions[i].id] = version_id
      end

      actions = DesignManagement::Action.unscoped.select(:design_id, :version_id, :event).where(design: designs, version: versions)
      new_rows = actions.map do |action|
        {
          design_id: design_id_map[action.design_id],
          version_id: version_id_map[action.version_id],
          event: action.event_before_type_cast
        }
      end

      ::Gitlab::Database.bulk_insert(
        DesignManagement::Action.table_name,
        new_rows
      )
    end

    def link_lfs_files!
      oids = blobs.map(&:lfs_oid)
      repository_type = to_repository.repo_type.name

      LfsObject.where(oid: oids).find_each(batch_size: 100) do |lfs_object|
        LfsObjectsProject.safe_find_or_create_by!(
          project: to_project,
          lfs_object: lfs_object,
          repository_type: repository_type
        )
      end
    end

    def create_commits!(new_version_ids)
      to_repository.create_if_not_exists

      target_branch = to_repository.root_ref || 'master'
      # {0=>:create, 1=>:update, 2=>:delete}
      event_enum_raw = DesignManagement::DesignAction::EVENT_FOR_GITALY_ACTION.invert

      DesignManagement::Version.unscoped.includes(actions: :design).where(id: new_version_ids).find_each(batch_size: 10) do |version|
        # blob.data is content of the LfsPointer file and not the
        # content # can be nil for deletions
        content = blobs.find { |b| b.commit_id == version.sha }&.data

        gitaly_actions = version.actions.map do |action|
          DesignManagement::DesignAction.new(
            action.design,
            event_enum_raw[action.event_before_type_cast],
            content
          )
        end

        sha = to_repository.multi_action(current_user,
          branch_name: target_branch,
          message: commit_message(version),
          actions: gitaly_actions.map(&:gitaly_action))

        # Update the version sha to reflect the git commit
        version.update_column(:sha, sha)
      end
    end

    def copy_notes!(new_design_ids)
      DesignManagement::Design.unscoped.where(id: new_design_ids).find_each(batch_size: 100) do |new_design|
        old_design = designs.find { |d| d.filename == new_design.filename }

        next unless old_design

        Notes::CopyService.new(old_design, new_design, current_user).execute
      end
    end

    # We need to fetch blob data in order to find the oids for LfsObjects
    # and also to save Gitaly Data
    def fetch_blobs
      blobs_at = []

      versions.each do |version|
        blobs_at += version.designs.map { |d| [version.sha, d.full_path] }
      end

      # Blobs are reasonably small in memory, as their data are simple LFS Pointer files
      repository.blobs_at(blobs_at)
    end

    def commit_message(version)
      "Copy commit #{version.sha} from issue #{issue.to_reference(full: true)}"
    end

    def attributes_config
      @attributes_config ||= YAML.load_file(attributes_config_file).symbolize_keys
    end

    def attributes_config_file
      Rails.root.join('ee/lib/gitlab/design_management/copy_designs_attributes.yml')
    end
  end
end
