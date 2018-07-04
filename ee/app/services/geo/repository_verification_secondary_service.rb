module Geo
  class RepositoryVerificationSecondaryService
    include Gitlab::Geo::ProjectLogHelpers

    def initialize(registry, type)
      @registry = registry
      @type     = type.to_sym
    end

    def execute
      return unless Gitlab::Geo.geo_database_configured?
      return unless Gitlab::Geo.secondary?
      return unless should_verify_checksum?

      verify_checksum
    end

    private

    attr_reader :registry, :type

    delegate :project, to: :registry

    def should_verify_checksum?
      return false if resync?

      primary_checksum.present? && primary_checksum != secondary_checksum
    end

    def resync?
      registry.public_send("resync_#{type}") # rubocop:disable GitlabSecurity/PublicSend
    end

    def primary_checksum
      project.repository_state.public_send("#{type}_verification_checksum") # rubocop:disable GitlabSecurity/PublicSend
    end

    def secondary_checksum
      registry.public_send("#{type}_verification_checksum_sha") # rubocop:disable GitlabSecurity/PublicSend
    end

    def verify_checksum
      checksum = calculate_checksum

      if mismatch?(checksum)
        update_registry!(mismatch: true, failure: "#{type.to_s.capitalize} checksum mismatch: #{repository.disk_path}")
      else
        update_registry!(checksum: checksum)
      end
    rescue ::Gitlab::Git::Repository::ChecksumError, Timeout::Error => e
      update_registry!(failure: "Error verifying #{type.to_s.capitalize} checksum: #{repository.disk_path}", exception: e)
    end

    def calculate_checksum
      repository.checksum
    rescue Gitlab::Git::Repository::NoRepository, Gitlab::Git::Repository::InvalidRepository
      Gitlab::Git::Repository::EMPTY_REPOSITORY_CHECKSUM
    end

    def mismatch?(checksum)
      primary_checksum != checksum
    end

    def update_registry!(checksum: nil, mismatch: false, failure: nil, exception: nil, details: {})
      attrs = {
        "#{type}_verification_checksum_sha" => checksum,
        "#{type}_checksum_mismatch" => mismatch,
        "last_#{type}_verification_failure" => failure
      }

      if failure
        log_error(failure, exception,
                  type: type,
                  repository_shard: project.repository_storage,
                  repsitory_disk_path: repository.disk_path
                 )
      end

      registry.update!(attrs)
    end

    def repository
      @repository ||=
        case type
        when :repository then project.repository
        when :wiki then project.wiki.repository
        end
    end
  end
end
