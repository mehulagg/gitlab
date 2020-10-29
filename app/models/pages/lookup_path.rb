# frozen_string_literal: true

module Pages
  class LookupPath
    def initialize(project, trim_prefix: nil, domain: nil)
      @project = project
      @domain = domain
      @trim_prefix = trim_prefix || project.full_path
    end

    def project_id
      project.id
    end

    def access_control
      project.private_pages?
    end

    def https_only
      domain_https = domain ? domain.https? : true
      project.pages_https_only? && domain_https
    end

    def source
      if artifacts_archive
        zip_source
      else
        file_source
      end
    end

    def prefix
      if project.pages_group_root?
        '/'
      else
        project.full_path.delete_prefix(trim_prefix) + '/'
      end
    end

    private

    attr_reader :project, :trim_prefix, :domain

    def artifacts_archive
      return unless Feature.enabled?(:pages_artifacts_archive, project)

      archive = project.pages_metadatum.artifacts_archive

      return unless archive&.file

      return if archive.file.file_storage?

      archive
    end

    def zip_source
      {
        type: 'zip',
        path: artifacts_archive.file.url(expire_at: 1.day.from_now)
      }
    end

    def file_source
      {
        type: 'file',
        path: File.join(project.full_path, 'public/')
      }
    end
  end
end
