# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::ListConfigVariablesService do
  include ReactiveCachingHelpers

  let(:project) { create(:project, :repository) }
  let(:user) { project.creator }
  let(:service) { described_class.new(project, user, sha: sha) }
  let(:result) { YAML.dump(ci_config) }

  subject { service.execute }

  before do
    stub_gitlab_ci_yml_for_sha(sha, result)
  end

  context 'when sending a valid sha' do
    let(:sha) { 'master' }
    let(:ci_config) do
      {
        variables: {
          KEY1: { value: 'val 1', description: 'description 1' },
          KEY2: { value: 'val 2', description: '' },
          KEY3: { value: 'val 3' },
          KEY4: 'val 4'
        },
        test: {
          stage: 'test',
          script: 'echo'
        }
      }
    end

    it 'returns variable list' do
      expect(subject['KEY1']).to eq({ value: 'val 1', description: 'description 1' })
      expect(subject['KEY2']).to eq({ value: 'val 2', description: '' })
      expect(subject['KEY3']).to eq({ value: 'val 3', description: nil })
      expect(subject['KEY4']).to eq({ value: 'val 4', description: nil })
    end
  end

  context 'when config has includes' do
    let(:sha) { 'master' }
    let(:ci_config) do
      {
        include: [{ local: 'other_file.yml' }],
        variables: {
          KEY1: { value: 'val 1', description: 'description 1' }
        },
        test: {
          stage: 'test',
          script: 'echo'
        }
      }
    end

    before do
      allow_next_instance_of(Repository) do |repository|
        allow(repository).to receive(:blob_data_at).with(sha, 'other_file.yml') do
          <<~HEREDOC
            variables:
              KEY2:
                value: 'val 2'
                description: 'description 2'
          HEREDOC
        end
      end
    end

    it 'returns variable list' do
      expect(subject['KEY1']).to eq({ value: 'val 1', description: 'description 1' })
      expect(subject['KEY2']).to eq({ value: 'val 2', description: 'description 2' })
    end
  end

  context 'when sending an invalid sha' do
    let(:sha) { 'invalid-sha' }
    let(:ci_config) { nil }

    it 'returns empty json' do
      expect(subject).to eq({})
    end
  end

  context 'when sending an invalid config' do
    let(:sha) { 'master' }
    let(:ci_config) do
      {
        variables: {
          KEY1: { value: 'val 1', description: 'description 1' }
        },
        test: {
          stage: 'invalid',
          script: 'echo'
        }
      }
    end

    it 'returns empty result' do
      expect(subject).to eq({})
    end
  end

  context 'when reading from cache', :use_clean_rails_memory_store_caching do
    let(:sha) { 'master' }
    let(:ci_config) { {} }
    let(:reactive_cache_params) { [project.id, user.id, sha] }
    let(:return_value) { { 'KEY1' => { value: 'val 1', description: 'description 1' } } }

    before do
      stub_reactive_cache(service, return_value, reactive_cache_params)
    end

    it 'returns variable list' do
      expect(subject).to eq(return_value)
    end
  end

  context 'when the cache is empty', :use_clean_rails_memory_store_caching do
    let(:sha) { 'master' }
    let(:ci_config) { {} }
    let(:reactive_cache_params) { [project.id, user.id, sha] }

    it 'enquques the worker to fill cache' do
      expect(ReactiveCachingWorker)
        .to receive(:perform_async)
        .with(service.class, service.id, *reactive_cache_params)

      expect(subject).to eq({})
    end
  end

  private

  def stub_gitlab_ci_yml_for_sha(sha, result)
    allow_any_instance_of(Repository)
        .to receive(:gitlab_ci_yml_for)
        .with(sha, '.gitlab-ci.yml')
        .and_return(result)
  end
end
