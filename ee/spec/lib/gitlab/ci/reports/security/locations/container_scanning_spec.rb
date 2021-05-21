# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::Security::Locations::ContainerScanning do
  let(:params) do
    {
      image: 'registry.gitlab.com/my/project:latest',
      operating_system: 'debian:9',
      package_name: 'glibc',
      package_version: '1.2.3'
    }
  end

  let(:mandatory_params) { %i[image operating_system] }
  let(:expected_fingerprint) { Digest::SHA1.hexdigest('registry.gitlab.com/my/project:glibc') }
  let(:expected_fingerprint_path) { 'registry.gitlab.com/my/project:glibc' }

  it_behaves_like 'vulnerability location'

  describe 'fingerprint' do
    sha1_of = -> (input) { Digest::SHA1.hexdigest(input) }

    subject { described_class.new(**params) }

    specify do
      params[:image] = 'alpine:3.7.3'
      expect(subject.fingerprint).to eq(sha1_of.call('alpine:3.7.3:glibc'))
    end

    specify do
      params[:image] = 'alpine:3.7'
      expect(subject.fingerprint).to eq(sha1_of.call('alpine:3.7:glibc'))
    end

    specify do
      params[:image] = 'alpine:8101518288111119448185914762536722131810'
      expect(subject.fingerprint).to eq(sha1_of.call('alpine:glibc'))
    end

    specify do
      params[:image] = 'alpine:1.0.0-beta'
      expect(subject.fingerprint).to eq(sha1_of.call('alpine:1.0.0-beta:glibc'))
    end

    specify do
      params[:image] = 'registry.gitlab.com/gitlab-org/security-products/analyzers/container-scanning/tmp:af864bd61230d3d694eb01d6205b268b4ad63ac0'
      expect(subject.fingerprint).to eq(sha1_of.call('registry.gitlab.com/gitlab-org/security-products/analyzers/container-scanning/tmp:glibc'))
    end

    specify do
      params[:image] = 'registry.gitlab.com/gitlab-org/security-products/tests/container-scanning/master:ec301f43f14a2b477806875e49cfc4d3fa0d22c3'
      expect(subject.fingerprint).to eq(sha1_of.call('registry.gitlab.com/gitlab-org/security-products/tests/container-scanning/master:glibc'))
    end

    specify do
      params[:image] = 'registry.gitlab.com/gitlab-org/security-products/dast/webgoat-8.0@sha256:bc09fe2e0721dfaeee79364115aeedf2174cce0947b9ae5fe7c33312ee019a4e'
      expect(subject.fingerprint).to eq(sha1_of.call('registry.gitlab.com/gitlab-org/security-products/dast/webgoat-8.0@sha256:glibc'))
    end
  end
end
