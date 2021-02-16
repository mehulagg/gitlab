# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Security::CiConfiguration::ApiFuzzing::CreateService do
  let(:service) { described_class.new(container: double(Project), current_user: double(User), params: params) }

  describe '#create' do
    subject { service.create[:yaml] }  # rubocop: disable Rails/SaveBang

    context 'when given an OPENAPI specification file' do
      let(:params) do
        {
          api_specification_file: 'https://api.gov/api_spec',
          auth_password: '$PASSWORD',
          auth_username: '$USERNAME',
          scan_mode: 'OPENAPI',
          scan_profile: 'Quick-10',
          target: 'https://api.gov'
        }
      end

      it 'returns the API fuzzing configuration based on the given parameters' do
        is_expected.to eq({
          'stages' => ['fuzz'],
          'include' => [{ 'template' => 'API-Fuzzing.gitlab-ci.yml' }],
          'variables' => {
            'FUZZAPI_HTTP_PASSWORD' => '$PASSWORD',
            'FUZZAPI_HTTP_USERNAME' => '$USERNAME',
            'FUZZAPI_OPENAPI' => 'https://api.gov/api_spec',
            'FUZZAPI_PROFILE' => 'Quick-10',
            'FUZZAPI_TARGET_URL' => 'https://api.gov'
          }
        })
      end
    end

    context 'when given a HAR specification file' do
      let(:params) do
        {
          api_specification_file: 'https://api.gov/api_spec',
          auth_password: '$PASSWORD',
          auth_username: '$USERNAME',
          scan_mode: 'HAR',
          scan_profile: 'Quick-10',
          target: 'https://api.gov'
        }
      end

      it 'returns the API fuzzing configuration based on the given parameters' do
        is_expected.to eq({
          'stages' => ['fuzz'],
          'include' => [{ 'template' => 'API-Fuzzing.gitlab-ci.yml' }],
          'variables' => {
            'FUZZAPI_HTTP_PASSWORD' => '$PASSWORD',
            'FUZZAPI_HTTP_USERNAME' => '$USERNAME',
            'FUZZAPI_HAR' => 'https://api.gov/api_spec',
            'FUZZAPI_PROFILE' => 'Quick-10',
            'FUZZAPI_TARGET_URL' => 'https://api.gov'
          }
        })
      end
    end

    context 'when values for optional variables are not given' do
      let(:params) do
        {
          api_specification_file: 'https://api.gov/api_spec',
          scan_mode: 'HAR',
          target: 'https://api.gov'
        }
      end

      it 'does not include them in the configuration' do
        is_expected.to eq({
          'stages' => ['fuzz'],
          'include' => [{ 'template' => 'API-Fuzzing.gitlab-ci.yml' }],
          'variables' => {
            'FUZZAPI_HAR' => 'https://api.gov/api_spec',
            'FUZZAPI_TARGET_URL' => 'https://api.gov'
          }
        })
      end
    end
  end
end
