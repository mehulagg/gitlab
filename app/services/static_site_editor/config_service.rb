# frozen_string_literal: true

module StaticSiteEditor
  class ConfigService < ::BaseContainerService
    ValidationError = Class.new(StandardError)

    def initialize(container:, current_user: nil, params: {})
      super

      @project = container
      @repository = project.repository
      @ref = params.fetch(:ref)
    end

    def execute
      check_access!
      load_config!

      ServiceResponse.success(payload: data)
    rescue ValidationError => e
      ServiceResponse.error(message: e.message)
    rescue => e
      Gitlab::ErrorTracking.track_and_raise_exception(e)
    end

    private

    attr_reader :config, :project, :repository, :ref

    def static_site_editor_config_file
      '.gitlab/static-site-editor.yml'
    end

    def check_access!
      unless can?(current_user, :download_code, project)
        raise ValidationError, 'Insufficient permissions to read configuration'
      end
    end

    def load_config!
      yaml = yaml_from_repo.presence || '{}'
      @config = Gitlab::StaticSiteEditor::Config::FileConfig.new(yaml)

      unless config.valid?
        raise ValidationError, config.errors.first
      end
    rescue Gitlab::StaticSiteEditor::Config::FileConfig::ConfigError => e
      raise ValidationError, e.message
    end

    def data
      check_for_duplicate_keys!
      generated_data.merge(file_data)
    end

    def generated_data
      @generated_data ||= Gitlab::StaticSiteEditor::Config::GeneratedConfig.new(
        project.repository,
        ref,
        params.fetch(:path),
        params[:return_url]
      ).data
    end

    def file_data
      @file_data ||= config.to_hash
    end

    def check_for_duplicate_keys!
      duplicate_keys = generated_data.keys & file_data.keys
      raise ValidationError.new("Duplicate key(s) '#{duplicate_keys}' found.") if duplicate_keys.present?
    end

    def yaml_from_repo
      # TODO: This may duplicate potentially expensive GRPC calls from GeneratedConfig, and could be
      #       DRYed up and/or memoized.
      project.repository.blob_data_at(ref, static_site_editor_config_file)
    rescue GRPC::NotFound
      # Return nil in the case of a GRPC::NotFound exception, so the default config will be used.
      # Allow any other unexpected exception will be tracked and re-raised.
      nil
    end
  end
end
