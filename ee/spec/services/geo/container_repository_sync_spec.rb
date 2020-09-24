# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::ContainerRepositorySync, :geo do
  let(:group) { create(:group, name: 'group') }
  let(:project) { create(:project, path: 'test', group: group) }

  let(:container_repository) do
    create(:container_repository, name: 'my_image', project: project)
  end

  # Break symbol will be removed if JSON encode/decode operation happens
  # so we use this to prove that it does not happen and we preserve original
  # human readable JSON
  let(:manifest) { "{\"schemaVersion\":2,\n\"layers\":[]}" }

  before do
    stub_container_registry_config(enabled: true,
                                   api_url: 'http://registry.gitlab',
                                   host_port: 'registry.gitlab')

    stub_registry_replication_config(enabled: true,
                                     primary_api_url: 'http://primary.registry.gitlab')

    stub_request(:get, "http://registry.gitlab/v2/group/test/my_image/tags/list")
      .with(
        headers: {
          'Accept' => 'application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json',
          'Authorization' => 'bearer token'
          })
      .to_return(
        status: 200,
        body: Gitlab::Json.dump(tags: %w(obsolete)),
        headers: { 'Content-Type' => 'application/json' })

    stub_request(:get, "http://primary.registry.gitlab/v2/group/test/my_image/tags/list")
      .with(
        headers: { 'Authorization' => 'bearer pull-token' })
      .to_return(
        status: 200,
        body: Gitlab::Json.dump(tags: %w(tag-to-sync)),
        headers: { 'Content-Type' => 'application/json' })

    stub_request(:head, "http://primary.registry.gitlab/v2/group/test/my_image/manifests/tag-to-sync")
      .with(
        headers: {
          'Accept' => 'application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json',
          'Authorization' => 'bearer pull-token'
        })
      .to_return(status: 200, body: "", headers: { 'docker-content-digest' => 'sha256:ccccc' })

    stub_request(:head, "http://registry.gitlab/v2/group/test/my_image/manifests/obsolete")
      .with(
        headers: {
          'Accept' => 'application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json',
          'Authorization' => 'bearer token'
        })
      .to_return(status: 200, body: "", headers: { 'docker-content-digest' => 'sha256:aaaaa' })

    stub_request(:get, "http://primary.registry.gitlab/v2/group/test/my_image/manifests/tag-to-sync")
      .with(
        headers: {
          'Accept' => 'application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json',
          'Authorization' => 'bearer pull-token'
        })
      .to_return(status: 200, body: manifest, headers: {})

    stub_request(:put, "http://registry.gitlab/v2/group/test/my_image/manifests/tag-to-sync")
      .with(
        body: manifest,
        headers: {
          'Accept' => 'application/vnd.docker.distribution.manifest.v2+json, application/vnd.oci.image.manifest.v1+json',
          'Authorization' => 'bearer token',
          'Content-Type' => 'application/json'
        })
      .to_return(status: 200, body: "", headers: {})
  end

  describe 'execute' do
    it 'determines list of tags to sync and to remove correctly' do
      expect(container_repository).to receive(:delete_tag_by_digest).with('sha256:aaaaa')
      expect_next_instance_of(described_class) do |instance|
        expect(instance).to receive(:sync_tag).with('tag-to-sync').and_call_original
      end

      described_class.new(container_repository).execute
    end

    context 'when primary repository has no tags' do
      it 'considers the primary repository empty and does not fail' do
        stub_request(:get, "http://primary.registry.gitlab/v2/group/test/my_image/tags/list")
          .with(
            headers: { 'Authorization' => 'bearer pull-token' })
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' })

        expect(container_repository).to receive(:delete_tag_by_digest).with('sha256:aaaaa')

        described_class.new(container_repository).execute
      end
    end
  end
end
