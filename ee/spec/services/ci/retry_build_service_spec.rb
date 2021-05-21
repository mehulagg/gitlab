# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Ci::RetryBuildService do
  it_behaves_like 'restricts access to protected environments'

  describe '#reprocess' do
    context 'when user has ability to execute build' do
      let_it_be(:namespace) { create(:namespace) }
      let_it_be(:ultimate_plan) { create(:ultimate_plan) }
      let_it_be(:plan_limits) { create(:plan_limits, plan: ultimate_plan) }
      let_it_be(:user) { create(:user) }

      let(:project) { create(:project, namespace: namespace, creator: user) }
      let(:build) { create(:ci_build, project: project) }

      subject(:service) { described_class.new(project, user) }

      let(:new_build) do
        travel_to(1.second.from_now) do
          service.reprocess!(build)
        end
      end

      before do
        stub_not_protect_default_branch

        project.add_developer(user)
      end

      context 'when build has secrets' do
        let(:secrets) do
          {
            'DATABASE_PASSWORD' => {
              'vault' => {
                'engine' => { 'name' => 'kv-v2', 'path' => 'kv-v2' },
                'path' => 'production/db',
                'field' => 'password'
              }
            }
          }
        end

        before do
          build.update!(secrets: secrets)
        end

        it 'clones secrets' do
          expect(new_build.secrets).to eq(secrets)
        end
      end

      describe 'credit card requirement' do
        before do
          create(:gitlab_subscription, namespace: namespace, hosted_plan: ultimate_plan)
        end

        shared_examples 'creates a retried build' do
          it 'creates a retried build' do
            build

            expect { new_build }.to change { Ci::Build.count }.by(1)

            expect(new_build.name).to eq build.name
            expect(new_build).to be_latest
            expect(build).to be_retried
            expect(build).to be_processed
          end
        end

        context 'when credit card is required' do
          context 'when project is on free plan' do
            before do
              allow(::Gitlab).to receive(:com?).and_return(true)
              namespace.gitlab_subscription.update!(hosted_plan: create(:free_plan))
              user.created_at = ::Users::CreditCardValidation::RELEASE_DAY
            end

            context 'when user has credit card' do
              before do
                allow(user).to receive(:credit_card_validated_at).and_return(Time.current)
              end

              it_behaves_like 'creates a retried build'
            end

            context 'when user does not have credit card' do
              it 'raises an exception', :aggregate_failures do
                expect { new_build }.to raise_error Gitlab::Access::AccessDeniedError
              end

              context 'when feature flag is disabled' do
                before do
                  stub_feature_flags(ci_require_credit_card_on_free_plan: false)
                end

                it_behaves_like 'creates a retried build'
              end
            end
          end
        end

        context 'when credit card is not required' do
          it_behaves_like 'creates a retried build'
        end
      end
    end
  end
end
