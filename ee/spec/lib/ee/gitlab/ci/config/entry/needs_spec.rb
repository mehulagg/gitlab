# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Ci::Config::Entry::Needs do
  subject(:needs) { described_class.new(config) }

  before do
    needs.metadata[:allowed_needs] = %i[job bridge cross_dependency]
  end

  describe 'validations' do
    before do
      needs.compose!
    end

    context 'when entry config value is correct' do
      let(:config) { ['job_name', pipeline: 'some/project'] }

      describe '#valid?' do
        it { is_expected.to be_valid }
      end
    end

    context 'when wrong needs type is used' do
      let(:config) { ['job_name', { pipeline: 'some/project' }, 123] }

      describe '#valid?' do
        it { is_expected.not_to be_valid }
      end

      describe '#errors' do
        it 'returns error about incorrect type' do
          expect(needs.errors).to contain_exactly(
            'need has an unsupported type')
        end
      end
    end

    context 'when bridge needs has wrong attributes' do
      let(:config) { ['job_name', project: 'some/project'] }

      describe '#valid?' do
        it { is_expected.not_to be_valid }
      end
    end

    context 'with too many cross dependencies' do
      let(:limit) { described_class::NEEDS_CROSS_DEPENDENCIES_LIMIT }

      let(:config) do
        Array.new(limit.next) do |index|
          {
            project: "project-#{index}",
            job: 'job-1',
            ref: 'master',
            artifacts: true
          }
        end
      end

      describe '#valid?' do
        it { is_expected.not_to be_valid }
      end

      describe '#errors' do
        it 'returns error about incorrect type' do
          expect(needs.errors).to contain_exactly(
            "needs config must be less than or equal to #{limit}")
        end
      end
    end
  end

  describe '.compose!' do
    context 'when valid job entries composed' do
      let(:config) do
        [
          'first_job_name',
          { job: 'second_job_name', artifacts: false },
          { pipeline: 'some/project' },
          { project: 'some/project', job: 'some/job', ref: 'some/ref', artifacts: true }
        ]
      end

      before do
        needs.compose!
      end

      it 'is valid' do
        expect(needs).to be_valid
      end

      describe '#value' do
        it 'returns key value' do
          expect(needs.value).to eq(
            job: [
              { name: 'first_job_name',  artifacts: true },
              { name: 'second_job_name', artifacts: false }
            ],
            bridge: [{ pipeline: 'some/project' }],
            cross_dependency: [
              {
                project: 'some/project',
                job: 'some/job',
                ref: 'some/ref',
                artifacts: true
              }
            ]
          )
        end
      end

      describe '#descendants' do
        it 'creates valid descendant nodes' do
          expect(needs.descendants.count).to eq(4)
          expect(needs.descendants)
            .to all(be_an_instance_of(::Gitlab::Ci::Config::Entry::Need))
        end
      end
    end
  end
end
