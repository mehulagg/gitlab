# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::SubscribableBannerHelper do
  describe '#gitlab_subscription_or_license' do
    subject { helper.gitlab_subscription_or_license }

    shared_examples 'when a subscription exists' do
      let(:gitlab_subscription) { build_stubbed(:gitlab_subscription) }

      it 'returns a decorator' do
        allow(entity).to receive(:closest_gitlab_subscription).and_return(gitlab_subscription)

        expect(subject).to be_a(SubscriptionPresenter)
      end
    end

    context 'when feature flag is enabled' do
      let(:license) { double(:license) }

      before do
        stub_feature_flags(subscribable_banner: true)
      end

      context 'when instance variable true' do
        before do
          assign(:display_subscription_banner, true)
        end

        context 'when should_check_namespace_plan is true' do
          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
          end

          context 'when a project exists' do
            let(:entity) { create(:project) }

            before do
              assign(:project, entity)
            end

            it_behaves_like 'when a subscription exists'
          end

          context 'when a group exists' do
            let(:entity) { create(:group) }

            before do
              assign(:group, entity)
            end

            it_behaves_like 'when a subscription exists'
          end
        end

        context 'when should_check_namespace_plan is false' do
          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(false)
          end

          it 'returns the current license' do
            expect(License).to receive(:current).and_return(license)
            expect(subject).to eq(license)
          end
        end
      end

      context 'when instance variable false' do
        before do
          assign(:display_subscription_banner, false)
          allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
        end

        it 'returns the current license' do
          expect(License).to receive(:current).and_return(license)
          expect(subject).to eq(license)
        end
      end
    end
  end

  describe '#gitlab_subscription_message_or_license_message' do
    subject { helper.gitlab_subscription_message_or_license_message }

    let(:message) { double(:message) }

    context 'when feature flag is enabled' do
      before do
        stub_feature_flags(subscribable_banner: true)
      end

      context 'when instance variable true' do
        before do
          assign(:display_subscription_banner, true)
        end

        context 'when should_check_namespace_plan is true' do
          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
          end

          let(:gitlab_subscription) { entity.closest_gitlab_subscription }
          let(:decorated_mock) { double(:decorated_mock) }
          let(:message_mock) { double(:message_mock) }
          let(:user) { double(:user_mock) }

          shared_examples 'subscription message' do
            it 'calls Gitlab::ExpiringSubscriptionMessage and SubscriptionPresenter if is Gitlab.com?' do
              allow(helper).to receive(:signed_in?).and_return(true)
              allow(helper).to receive(:current_user).and_return(user)
              allow(helper).to receive(:can?).with(user, :owner_access, entity).and_return(true)

              expect(SubscriptionPresenter).to receive(:new).with(gitlab_subscription).and_return(decorated_mock)
              expect(::Gitlab::ExpiringSubscriptionMessage).to receive(:new).with(
                subscribable: decorated_mock,
                signed_in: true,
                is_admin: true,
                namespace: namespace
              ).and_return(message_mock)
              expect(message_mock).to receive(:message).and_return('hey yay yay yay')

              expect(subject).to eq('hey yay yay yay')
            end
          end

          context 'when a project is present' do
            let(:entity) { create(:project, namespace: namespace) }
            let(:namespace) { create(:namespace_with_plan) }

            before do
              assign(:project, entity)
            end

            it_behaves_like 'subscription message'
          end

          context 'when a group is present' do
            let(:entity) { create(:group_with_plan) }
            let(:namespace) { entity }

            before do
              assign(:project, nil)
              assign(:group, entity)
            end

            it_behaves_like 'subscription message'
          end
        end

        context 'when should_check_namespace_plan is false' do
          let(:license) { double(:license) }
          let(:message_mock) { double(:message_mock) }
          let(:user) { double(:user) }

          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(false)
            allow(License).to receive(:current).and_return(license)
            allow(helper).to receive(:current_user).and_return(user)
            allow(helper).to receive(:signed_in?).and_return(true)
            allow(user).to receive(:admin?).and_return(false)
          end

          it 'calls Gitlab::ExpiringSubscriptionMessage to get expiring message' do
            expect(Gitlab::ExpiringSubscriptionMessage).to receive(:new).with(
              subscribable: license,
              signed_in: true,
              is_admin: false
            ).and_return(message_mock)

            expect(message_mock).to receive(:message)

            subject
          end
        end
      end

      context 'when instance variable false' do
        before do
          assign(:display_subscription_banner, false)
          allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
        end

        it 'returns the license message' do
          expect(helper).to receive(:license_message).and_return(message)
          expect(subject).to eq(message)
        end
      end
    end
  end

  describe '#display_subscription_banner!' do
    it 'sets @display_subscription_banner to true' do
      expect(helper.instance_variable_get(:@display_subscription_banner)).to be nil

      helper.display_subscription_banner!

      expect(helper.instance_variable_get(:@display_subscription_banner)).to be true
    end
  end
end
