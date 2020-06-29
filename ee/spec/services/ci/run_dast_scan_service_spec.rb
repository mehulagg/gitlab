# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::RunDastScanService do
  let(:project) { create(:project) }
  let(:branch) { SecureRandom.hex }
  let(:target_url) { FFaker::Internet.uri(:http) }
  let(:user) { create(:user) }

  describe '#execute' do
    subject { described_class.new(project: project, user: user).execute(branch: branch, target_url: target_url) }

    context 'when the user does not have permission to run a dast scan' do
      it 'raises an exeception with #full_messages populated' do
        expect { subject }.to raise_error(Ci::RunDastScanService::RunError) do |error|
          expect(error.full_messages[0]).to include('you don\'t have permission to perform this action')
        end
      end
    end

    context 'when the user can run a dast scan' do
      before do
        project.add_developer(user)
      end

      it 'returns a pipeline' do
        expect(subject).to be_a(Ci::Pipeline)
      end

      it 'creates a pipeline' do
        expect { subject }.to change(Ci::Pipeline, :count).by(1)
      end

      it 'sets the pipeline ref to the branch' do
        expect(subject.ref).to eq(branch)
      end

      it 'sets the source to indicate an ondemand scan' do
        expect(subject.source).to eq('ondemand_scan')
      end

      it 'creates a stage' do
        expect { subject }.to change(Ci::Stage, :count).by(1)
      end

      it 'creates a build' do
        expect { subject }.to change(Ci::Build, :count).by(1)
      end

      it 'sets the build name to indicate a DAST scan' do
        build = subject.builds.first
        expect(build.name).to eq('DAST Scan')
      end

      it 'creates a build with appropriate options' do
        build = subject.builds.first
        expected_options = {
          'image' => {
            'name' => '$SECURE_ANALYZERS_PREFIX/dast:$DAST_VERSION'
          },
          'script' => [
            'export DAST_WEBSITE=${DAST_WEBSITE:-$(cat environment_url.txt)}',
            '/analyze'
          ],
          'artifacts' => {
            'reports' => {
              'dast' => ['gl-dast-report.json']
            }
          }
        }
        expect(build.options).to eq(expected_options)
      end

      it 'creates a build with appropriate variables' do
        build = subject.builds.first
        expected_variables = [
          {
            'key' => 'DAST_VERSION',
            'value' => '1',
            'public' => true
          }, {
            'key' => 'SECURE_ANALYZERS_PREFIX',
            'value' => 'registry.gitlab.com/gitlab-org/security-products/analyzers',
            'public' => true
          }, {
            'key' => 'DAST_WEBSITE',
            'value' => target_url,
            'public' => true
          }, {
            'key' => 'GIT_STRATEGY',
            'value' => 'none',
            'public' => true
          }
        ]
        expect(build.yaml_variables).to eq(expected_variables)
      end

      it 'enqueues a build' do
        build = subject.builds.first
        expect(build.queued_at).not_to be_nil
      end

      context 'when the repository has no commits' do
        it 'uses a placeholder' do
          expect(subject.sha).to eq('placeholder')
        end
      end

      context 'when the pipeline could not be created' do
        before do
          allow(Ci::Pipeline).to receive(:create!).and_raise(StandardError)
        end

        it 'raises an exeception with #full_messages populated' do
          expect { subject }.to raise_error(Ci::RunDastScanService::RunError) do |error|
            expect(error.full_messages).to include('Pipeline could not be created')
          end
        end
      end

      context 'when the stage could not be created' do
        before do
          allow(Ci::Stage).to receive(:create!).and_raise(StandardError)
        end

        it 'raises an exeception with #full_messages populated' do
          expect { subject }.to raise_error(Ci::RunDastScanService::RunError) do |error|
            expect(error.full_messages).to include('Stage could not be created')
          end
        end

        it 'does not create a pipeline' do
          expect { subject rescue nil }.not_to change(Ci::Pipeline, :count)
        end
      end

      context 'when the build could not be created' do
        before do
          allow(Ci::Build).to receive(:create!).and_raise(StandardError)
        end

        it 'raises an exeception with #full_messages populated' do
          expect { subject }.to raise_error(Ci::RunDastScanService::RunError) do |error|
            expect(error.full_messages).to include('Build could not be created')
          end
        end

        it 'does not create a stage' do
          expect { subject rescue nil }.not_to change(Ci::Pipeline, :count)
        end
      end

      context 'when the build could not be enqueued' do
        before do
          allow_any_instance_of(Ci::Build).to receive(:enqueue!).and_raise(StandardError)
        end

        it 'raises an exeception with #full_messages populated' do
          expect { subject }.to raise_error(Ci::RunDastScanService::RunError) do |error|
            expect(error.full_messages).to include('Build could not be enqueued')
          end
        end

        it 'does not create a build' do
          expect { subject rescue nil }.not_to change(Ci::Pipeline, :count)
        end
      end

      context 'when a validation error is raised' do
        before do
          klass = Ci::Pipeline
          allow(klass).to receive(:create!).and_raise(
            ActiveRecord::RecordInvalid, klass.new.tap do |pl|
              pl.errors.add(:sha, 'can\'t be blank')
            end
          )
        end

        it 'raises an exeception with #full_messages populated' do
          expect { subject }.to raise_error(Ci::RunDastScanService::RunError) do |error|
            expect(error.full_messages).to include('Sha can\'t be blank')
          end
        end
      end
    end
  end
end
