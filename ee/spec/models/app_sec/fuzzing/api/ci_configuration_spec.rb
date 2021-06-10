# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AppSec::Fuzzing::API::CiConfiguration do
  include StubRequests

  describe '#scan_profiles' do
    context 'when the request finishes successfully' do
      it 'returns all scan profiles' do
        profiles_yaml = YAML.dump(Profiles: [{ Name: 'Quick-10' }])
        stub_full_request(
          described_class::PROFILES_DEFINITION_FILE
        ).to_return(body: profiles_yaml)

        profiles = described_class.new(project: double(Project)).scan_profiles

        expect(profiles.first.name).to eq('Quick-10')
      end

      it 'caches the response' do
        profiles_yaml = [{ Name: 'Quick-10' }]
        allow(Rails.cache).to receive(:fetch).and_return(profiles_yaml)

        profiles = described_class.new(project: double(Project)).scan_profiles

        expect(profiles.first.name).to eq('Quick-10')
        expect(Rails.cache).to have_received(:fetch)
          .with(described_class::SCAN_PROFILES_CACHE_KEY, expires_in: 1.hour)
      end

      context 'when the response includes unknown scan profiles' do
        it 'excludes them from the returned profiles' do
          profiles_yaml = YAML.dump(Profiles: [{ Name: 'UNKNOWN!' }])
          stub_full_request(
            described_class::PROFILES_DEFINITION_FILE
          ).to_return(body: profiles_yaml)

          profiles = described_class.new(project: double(Project)).scan_profiles

          expect(profiles).to be_empty
        end
      end
    end

    context 'when the request errors' do
      it 'returns an empty array' do
        allow(Gitlab::HTTP).to receive(:try_get)

        profiles = described_class.new(project: double(Project)).scan_profiles

        expect(profiles).to be_empty
      end
    end

    context 'when the request returns an unsuccessful status code' do
      it 'returns an empty array' do
        stub_full_request(
          described_class::PROFILES_DEFINITION_FILE
        ).to_return(status: [500, 'everything is broken'])

        profiles = described_class.new(project: double(Project)).scan_profiles

        expect(profiles).to be_empty
      end
    end
  end
end
