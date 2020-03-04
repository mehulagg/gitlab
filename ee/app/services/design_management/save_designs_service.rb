# frozen_string_literal: true

module DesignManagement
  class SaveDesignsService < DesignService
    include RunsDesignActions
    include OnSuccessCallbacks

    MAX_FILES = 10

    def initialize(project, user, params = {})
      super

      @files = params.fetch(:files)
    end

    def execute
      return error("Not allowed!") unless can_create_designs?
      return error("Only #{MAX_FILES} files are allowed simultaneously") if files.size > MAX_FILES

      repository.create_if_not_exists

      uploaded_designs = upload_designs!
      skipped_designs = designs - uploaded_designs

      # Create a Geo event so changes will be replicated to secondary node(s)
      repository.log_geo_updated_event

      success({ designs: uploaded_designs, skipped_designs: skipped_designs })
    rescue ::ActiveRecord::RecordInvalid => e
      error(e.message)
    end

    private

    attr_reader :files

    def upload_designs!
      actions = build_actions
      return [] if actions.empty?

      version = run_actions(actions, current_user)
      ::DesignManagement::NewVersionWorker.perform_async(version.id)

      actions.map(&:design)
    end

    # Returns `Design` instances that correspond with `files`.
    # New `Design`s will be created where a file name does not match
    # an existing `Design`
    def designs
      @designs ||= files.map do |file|
        collection.find_or_create_design!(filename: file.original_filename)
      end
    end

    def build_actions
      files.zip(designs).flat_map do |(file, design)|
        Array.wrap(build_design_action(file, design))
      end
    end

    def build_design_action(file, design)
      content = file_content(file, design.full_path)
      return if design_unchanged?(design, content)

      action = new_file?(design) ? :create : :update
      on_success { ::Gitlab::UsageCounters::DesignsCounter.count(action) }

      DesignManagement::DesignAction.new(design, action, content)
    end

    # Returns true if the design file is the same as its latest version
    def design_unchanged?(design, content)
      content == existing_blobs[design]&.data
    end

    def commit_message
      <<~MSG
      Updated #{files.size} #{'designs'.pluralize(files.size)}

      #{formatted_file_list}
      MSG
    end

    def formatted_file_list
      filenames.map { |name| "- #{name}" }.join("\n")
    end

    def filenames
      @filenames ||= files.map(&:original_filename)
    end

    def can_create_designs?
      Ability.allowed?(current_user, :create_design, issue)
    end

    def new_file?(design)
      !existing_blobs[design]
    end

    def file_content(file, full_path)
      transformer = ::Lfs::FileTransformer.new(project, repository, target_branch)
      transformer.new_file(full_path, file.to_io).content
    end

    # Returns the latest blobs for the designs as a Hash of `{ Design => Blob }`
    def existing_blobs
      @existing_blobs ||= begin
        items = designs.map { |d| ['HEAD', d.full_path] }

        repository.blobs_at(items).each_with_object({}) do |blob, h|
          design = designs.find { |d| d.full_path == blob.path }

          h[design] = blob
        end
      end
    end
  end
end
