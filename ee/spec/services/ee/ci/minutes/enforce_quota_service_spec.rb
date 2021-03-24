# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Ci::Minutes::EnforceQuotaService do
  include AfterNextHelpers

  let_it_be(:namespace, reload: true) { create(:namespace) }
  let_it_be(:project, reload: true) { create(:project, :repository, namespace: namespace) }

  let(:service) { described_class.new(project, nil) }

  describe '#conditionally_execute_async', :redis do
    # TODO
  end

  describe '#execute', :redis do
    subject { service.execute }

    context 'when CI minutes are disabled for the project' do
      before do
        project.update!(shared_runners_enabled: false)
      end

      it 'exits immediately' do
        expect(Gitlab::Redis::SharedState).not_to receive(:with)

        subject
      end
    end

    context 'when CI minutes are enabled for the namespace' do
      before do
        allow(project).to receive(:shared_runners_minutes_limit_enabled?).and_return(true)
        allow_next(Ci::Minutes::Quota).to receive(:total_minutes_remaining).and_return(10)
      end

      context 'when service has run recently' do
        before do
          service.lock_namespace_check
        end

        it 'exits immediately' do
          expect(service).not_to receive(:in_lock)

          subject
        end
      end

      context 'when service has not run recently' do
        context 'when exclusive lease is not taken' do
          context 'when there builds being run by shared runners' do
            let(:shared_runner) { create(:ci_runner, :instance) }
            let(:specific_runner) { create(:ci_runner, :project, :online, :tagged_only, projects: [project], tag_list: ['linux']) }

            let!(:running_build_by_shared_runner) do
              create(:ci_build, :running,
                name: 'running_build_by_shared_runner',
                started_at: 1.minute.ago,
                project: project,
                runner: shared_runner)
            end

            let!(:running_build_by_specific_runner) do
              create(:ci_build, :running,
                name: 'running_build_by_specific_runner',
                started_at: 1.minute.ago,
                project: project,
                runner: specific_runner)
            end

            let!(:pending_build_for_specific_runner) do
              create(:ci_build, :pending,
                name: 'pending_build_for_specific_runner',
                project: project,
                tag_list: ['linux'])
            end

            let!(:pending_build_for_shared_runner) do
              create(:ci_build, :pending,
                name: 'pending_build_for_shared_runner',
                project: project)
            end

            context 'when builds being run by shared runner cause runtime consumption to exceed the quota and the grace period' do
              before do
                running_build_by_shared_runner.update!(started_at: 31.minutes.ago)
              end

              it 'drops the build running on the shared runner' do
                subject

                running_build_by_shared_runner.reload
                expect(running_build_by_shared_runner).to be_failed
                expect(running_build_by_shared_runner.failure_reason).to eq('ci_quota_exceeded')
              end

              it 'drops pending builds that do not match specific runners' do
                subject

                pending_build_for_shared_runner.reload
                expect(pending_build_for_shared_runner).to be_failed
                expect(pending_build_for_shared_runner.failure_reason).to eq('ci_quota_exceeded')
              end

              it 'does not drop build running on specific runners' do
                expect { subject }.not_to change { running_build_by_specific_runner.reload.status }
              end

              it 'does not drop build pending on specific runners' do
                expect { subject }.not_to change { pending_build_for_specific_runner.reload.status }
              end
            end

            context 'when builds being run by shared runner cause runtime consumption to exceed the quota but not the grace period' do
              before do
                running_build_by_shared_runner.update!(started_at: 30.minutes.ago)
              end

              it 'does not drop the running build for shared runner' do
                expect { subject }.not_to change { running_build_by_shared_runner.reload.status }
              end

              it 'does not drop the pending build for shared runner' do
                expect { subject }.not_to change { pending_build_for_shared_runner.reload.status }
              end

              it 'does not drop build running on specific runners' do
                expect { subject }.not_to change { running_build_by_specific_runner.reload.status }
              end

              it 'does not drop build pending on specific runners' do
                expect { subject }.not_to change { pending_build_for_specific_runner.reload.status }
              end
            end

            context 'when builds being run by specific runner cause runtime consumption to exceed the quota and the grace period' do
              before do
                running_build_by_specific_runner.update!(started_at: 30.minutes.ago)
              end

              it 'does not drop the running build for shared runner' do
                expect { subject }.not_to change { running_build_by_shared_runner.reload.status }
              end

              it 'does not drop the pending build for shared runner' do
                expect { subject }.not_to change { pending_build_for_shared_runner.reload.status }
              end

              it 'does not drop build running on specific runners' do
                expect { subject }.not_to change { running_build_by_specific_runner.reload.status }
              end

              it 'does not drop build pending on specific runners' do
                expect { subject }.not_to change { pending_build_for_specific_runner.reload.status }
              end
            end
          end
        end

        context 'when exclusive lease is taken' do
          it 'exits immediately'
        end
      end
    end
  end
end
