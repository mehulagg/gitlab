# frozen_string_literal: true

# Service to copy a DesignCollection from one Issue to another.
# Copies the DesignCollection's Designs, Versions, and Notes on Designs.
module DesignManagement
  module CopyDesignCollection
    class CopyService < DesignService
      include RunsDesignActions

      # rubocop: disable CodeReuse/ActiveRecord
      def initialize(project, user, params = {})
        super

        @target_issue = params.fetch(:target_issue)
        @target_project = @target_issue.project
        @target_repository = @target_project.design_repository
        @target_design_collection = @target_issue.design_collection
        @temporary_branch = "CopyDesignCollectionService_#{SecureRandom.hex}"

        @designs = DesignManagement::Design.unscoped.where(issue: issue).order(:id).to_a
        @versions = DesignManagement::Version.unscoped.where(issue: issue).order(:id).to_a

        @event_enum_map = DesignManagement::DesignAction::EVENT_FOR_GITALY_ACTION.invert
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def execute
        return error('User cannot copy design collection to issue') unless user_can_copy?
        return error('Target design collection must first be queued') unless target_design_collection.copy_in_progress?
        return error('Design collection has no designs') if design_collection.empty?
        return error('Target design collection already has designs') unless target_design_collection.empty?

        with_temporary_branch do
          ActiveRecord::Base.transaction do
            design_ids = copy_designs!

            new_designs = DesignManagement::Design.unscoped.find(design_ids)
            @new_designs_by_filename = new_designs.to_h { |d| [d.filename, d] }

            copy_notes!
            link_lfs_files!
            copy_versions!
            finalize!
          end
        end

        ServiceResponse.success
      rescue => error
        log_exception(error)

        target_design_collection.error_copy!

        error('Designs were unable to be copied successfully')
      end

      private

      attr_reader :designs, :event_enum_map, :new_designs_by_filename, :temporary_branch,
                  :target_design_collection, :target_issue, :target_repository, :target_project, :versions

      alias_method :merge_branch, :target_branch

      def log_exception(exception)
        payload = {
          issue_id: issue.id,
          project_id: project.id,
          target_issue_id: target_issue.id,
          target_project: target_project.id
        }

        Gitlab::ErrorTracking.track_exception(exception, payload)
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def user_can_copy?
        current_user.can?(:read_design, design_collection) &&
          current_user.can?(:admin_issue, target_issue)
      end

      def with_temporary_branch(&block)
        target_repository.create_if_not_exists

        create_master_branch! if target_repository.empty?
        create_temporary_branch!

        yield
      ensure
        remove_temporary_branch!
      end

      # A project that does not have any designs will have a blank design
      # repository. To create a temporary branch from `master` we need
      # create `master` first by adding a file to it.
      def create_master_branch!
        target_repository.create_file(
          current_user,
          ".CopyDesignCollectionService_#{Time.now.to_i}",
          '.gitlab',
          message: "Commit to create #{merge_branch} branch in CopyDesignCollectionService",
          branch_name: merge_branch
        )
      end

      def create_temporary_branch!
        target_repository.add_branch(
          current_user,
          temporary_branch,
          target_repository.root_ref
        )
      end

      def remove_temporary_branch!
        return unless target_repository.branch_exists?(temporary_branch)

        target_repository.rm_branch(current_user, temporary_branch)
      end

      def finalize!
        source_sha = target_repository.commit(temporary_branch)&.id

        return unless source_sha

        target_repository.raw.merge(
          current_user,
          source_sha,
          merge_branch,
          'CopyDesignCollectionService finalize merge'
        ) { nil }

        target_design_collection.end_copy!
      end

      def copy_designs!
        design_attributes = attributes_config[:design_attributes]

        new_rows = designs.map do |design|
          design.attributes.slice(*design_attributes).merge(
            issue_id: target_issue.id,
            project_id: target_project.id
          )
        end

        # TODO Replace `Gitlab::Database.bulk_insert` with `BulkInsertSafe`
        # once https://gitlab.com/gitlab-org/gitlab/-/issues/247718 is fixed.
        ::Gitlab::Database.bulk_insert( # rubocop:disable Gitlab/BulkInsert
          DesignManagement::Design.table_name,
          new_rows,
          return_ids: true
        )
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def copy_versions!
        version_attributes = attributes_config[:version_attributes]

        # Re-scope versions to eagerly load association data for `#build_design_actions`
        DesignManagement::Version.unscoped.where(id: versions).includes(actions: :design).find_each(batch_size: 100) do |version|
          design_actions = build_design_actions(version)

          new_version = DesignManagement::Version.with_lock(target_project.id, target_repository) do
            run_actions(
              design_actions,
              repository: target_repository,
              target_branch: temporary_branch,
              commit_message: commit_message(version),
              skip_system_notes: true
            )
          end

          new_attributes = version.attributes.slice(*version_attributes)
          new_version.update_columns(new_attributes)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def build_design_actions(version)
        version.actions.map do |action|
          design = new_designs_by_filename[action.design.filename]
          # `content` will be the LfsPointer file and not the design file,
          # and can be nil for deletions
          content = blobs.dig(version.sha, design.filename)&.data

          DesignManagement::DesignAction.new(
            design,
            event_enum_map[action.event_before_type_cast],
            content
          )
        end
      end

      def commit_message(version)
        "Copy commit #{version.sha} from issue #{issue.to_reference(full: true)}"
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def copy_notes!
        # Execute another query to filter only designs with notes
        DesignManagement::Design.unscoped.where(id: designs).joins(:notes).find_each(batch_size: 100) do |old_design|
          new_design = new_designs_by_filename[old_design.filename]

          Notes::CopyService.new(current_user, old_design, new_design).execute
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def link_lfs_files!
        oids = blobs.values.flat_map(&:values).map(&:lfs_oid)

        LfsObject.where(oid: oids).find_each(batch_size: 100) do |lfs_object|
          LfsObjectsProject.safe_find_or_create_by!(
            project: target_project,
            lfs_object: lfs_object,
            repository_type: :design
          )
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # Blob data is used to find the oids for LfsObjects and to copy to Git.
      # Blobs are reasonably small in memory, as their data are LFS Pointer files.
      #
      # Returns all blobs for the designs as a Hash of `{ Blob#commit_id => { Design#filename => Blob } }`
      def blobs
        @blobs ||= begin
          items = versions.flat_map { |v| v.designs.map { |d| [v.sha, d.full_path] } }

          repository.blobs_at(items).each_with_object({}) do |blob, h|
            design = designs.find { |d| d.full_path == blob.path }

            h[blob.commit_id] ||= {}
            h[blob.commit_id][design.filename] = blob
          end
        end
      end

      def attributes_config
        @attributes_config ||= YAML.load_file(attributes_config_file).symbolize_keys
      end

      def attributes_config_file
        Rails.root.join('lib/gitlab/design_management/copy_design_collection_model_attributes.yml')
      end
    end
  end
end
