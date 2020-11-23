# frozen_string_literal: true

require 'spec_helper'

RSpec.describe  ScanSecurityReportSecretsWorker do
  let(:project) { create(:project, :repository) }
  let(:pipeline) { create(:ci_pipeline, :success, project: project) }

  let(:secret_detection_build) { create(:ci_build, :secret_detection, pipeline: pipeline) }
  let(:file) { 'aws-key1.py' }
  let(:api_key) { 'AKIALALEMEM35243O567' }
  let(:identifier_type) { 'gitleaks_rule_id' }
  let(:identifier_value) { 'AWS' }
  let(:revocation_key_type) { 'gitleaks_rule_id_aws' }

  let(:vulnerability) do
    create(:vulnerabilities_finding, :with_secret_detection, pipelines: [pipeline], project: project)
  end

  subject(:worker) { described_class.new }

  before do
    vulnerability.update!(raw_metadata: { category: 'secret_detection',
          raw_source_code_extract: api_key,
          location: { file: file,
                      start_line: 40, end_line: 45 },
                      identifiers: [{ type: identifier_type, name: 'Gitleaks rule ID AWS', value: identifier_value }] }.to_json)
  end

  describe '#perform' do
    include_examples 'an idempotent worker' do
      let(:job_args) { [secret_detection_build.id] }

      before do
        allow_next_instance_of(Security::TokenRevocationService) do |revocation_service|
          allow(revocation_service).to receive(:execute).and_return({ message: '', status: :success })
        end
      end

      it 'executes the service' do
        expect_next_instance_of(Security::TokenRevocationService) do |revocation_service|
          expect(revocation_service).to receive(:execute).and_return({ message: '', status: :success })
        end

        worker.perform(secret_detection_build.id)
      end
    end

    context 'with a failure in TokenRevocationService call' do
      before do
        allow_next_instance_of(Security::TokenRevocationService) do |revocation_service|
          allow(revocation_service).to receive(:execute).and_return({ message: 'This is an error', status: :error })
        end
      end

      it 'does not execute the service' do
        expect { worker.perform(secret_detection_build.id) }.to raise_error('This is an error')
      end
    end
  end

  describe '#revocable_keys' do
    it 'returns a list of revocable_keys' do
      key = worker.send(:revocable_keys, secret_detection_build).first

      expect(key[:type]).to eql(revocation_key_type)
      expect(key[:token]).to eql(api_key)
      expect(key[:location]).to include(file)
    end
  end
end
