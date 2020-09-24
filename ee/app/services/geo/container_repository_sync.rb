# frozen_string_literal: true

require 'tempfile'

module Geo
  class ContainerRepositorySync
    include Gitlab::Utils::StrongMemoize

    attr_reader :name, :container_repository

    def initialize(container_repository)
      @container_repository = container_repository
      @name = container_repository.path
    end

    def execute
      tags_to_sync.each do |tag|
        sync_tag(tag[:name])
      end

      tags_to_remove.each do |tag|
        container_repository.delete_tag_by_digest(tag[:digest])
      end

      true
    end

    private

    def sync_tag(tag)
      file = nil
      manifest = client.repository_raw_manifest(name, tag)
      manifest_parsed = Gitlab::Json.parse(manifest)

      list_blobs(manifest_parsed).each do |digest|
        next if container_repository.blob_exists?(digest)

        file = client.pull_blob(name, digest)
        container_repository.push_blob(digest, file.path)
        file.unlink
      end

      container_repository.push_manifest(tag, manifest, manifest_parsed['mediaType'])
    ensure
      file.try(:unlink)
    end

    def list_blobs(manifest)
      layers = manifest['layers'].map do |layer|
        layer['digest']
      end

      layers.push(manifest.dig('config', 'digest')).compact
    end

    def primary_tags
      @primary_tags ||= begin
        manifest = client.repository_tags(name)

        return [] unless manifest && manifest['tags']

        manifest['tags'].map do |tag|
          { name: tag, digest: client.repository_tag_digest(name, tag) }
        end
      end
    end

    def secondary_tags
      @secondary_tags ||= begin
        container_repository.tags.map do |tag|
          { name: tag.name, digest: tag.digest }
        end
      end
    end

    def tags_to_sync
      primary_tags - secondary_tags
    end

    def tags_to_remove
      secondary_tags - primary_tags
    end

    # The client for primary registry
    def client
      strong_memoize(:client) do
        ContainerRegistry::Client.new(
          Gitlab.config.geo.registry_replication.primary_api_url,
          token: ::Auth::ContainerRegistryAuthenticationService.pull_access_token(name)
        )
      end
    end
  end
end
