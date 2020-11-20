# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ci::ConfigResolver do
  include GraphqlHelpers

  describe '#resolve' do
    context 'with a valid .gitlab-ci.yml' do
      let_it_be(:content) do
        File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci_includes.yml'))
      end

      it 'lints the ci config file' do
        response = resolve(described_class, args: { content: content, include_merged_yaml: false }, ctx: {})

        expect(response[:status]).to eq('valid')
        expect(response[:errors]).to be_empty
      end

      it 'returns the correct structure' do
        response = resolve(described_class, args: { content: content, include_merged_yaml: false }, ctx: {})

        response_groups = response[:stages].map { |stage| stage[:groups] }.flatten
        response_jobs = response.dig(:stages, 0, :groups, 0, :jobs)
        response_needs = response.dig(:stages, -1, :groups, 0, :jobs, 0, :needs)

        expect(response[:stages]).to include(
          hash_including(name: 'build'), hash_including(name: 'test')
        )
        expect(response_groups).to include(
          hash_including(name: 'rspec', size: 2),
          hash_including(name: 'spinach', size: 1),
          hash_including(name: 'docker', size: 1)
        )

        expect(response_jobs).to include(
          hash_including(group_name: 'rspec', name: :'rspec 0 1', needs: [], stage: 'build'),
          hash_including(group_name: 'rspec', name: :'rspec 0 2', needs: [], stage: 'build')
        )
        expect(response_needs).to include(
          hash_including(name: 'rspec 0 1'), hash_including(name: 'spinach')
        )
      end
    end

    context 'with an invalid .gitlab-ci.yml' do
      it 'responds with errors about invalid syntax' do
        response = resolve(described_class, args: { content: 'invalid', include_merged_yaml: false }, ctx: {})

        expect(response[:status]).to eq('invalid')
        expect(response[:errors]).to eq(['Invalid configuration format'])
      end
    end
  end
end
