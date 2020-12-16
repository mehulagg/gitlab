namespace :gitlab do
  namespace :pages do
    desc "GitLab | Pages | Migrate legacy storage to zip format"
    task migrate_legacy_storage: :gitlab_environment do
      ProjectPagesMetadatum.deployed.where(pages_deployment: nil).find_each do |metadatum|
        # Shall we increase any metric here?
        # TODO: puts some debug info
        ::Pages::MigrateLegacyStorageToDeploymentService.new(metadatum.project).execute
      rescue => e
        puts e
        # TODO: rescue errors/print/report to sentry. Increase any metric?
      end
    end
  end
end
