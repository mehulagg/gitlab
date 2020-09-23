# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Minutes::EmailNotificationService do
  shared_examples 'namespace with available CI minutes' do
    context 'when usage is below the quote' do
      it 'does not send the email' do
        expect(CiMinutesUsageMailer).not_to receive(:notify)

        subject
      end
    end
  end

  shared_examples 'namespace with all CI minutes used' do
    context 'when usage is over the quote' do
      it 'sends the email to the owner' do
        expect(CiMinutesUsageMailer).to receive(:notify).once.with(namespace, [user.email]).and_return(spy)

        subject
      end
    end
  end

  let(:project) { create(:project, namespace: namespace) }
  let(:user) { create(:user) }
  let(:user_2) { create(:user) }

  let(:ci_minutes_used) { 0 }
  let!(:namespace_statistics) do
    create(:namespace_statistics, namespace: namespace, shared_runners_seconds: ci_minutes_used * 60)
  end

  describe '#execute' do
    let(:extra_ci_minutes) { 0 }
    let(:namespace) do
      create(:namespace, shared_runners_minutes_limit: 2000, extra_shared_runners_minutes_limit: extra_ci_minutes)
    end

    subject { described_class.new(project).execute }

    context 'with a personal namespace' do
      before do
        namespace.update!(owner_id: user.id)
      end

      it_behaves_like 'namespace with available CI minutes' do
        let(:ci_minutes_used) { 1900 }
      end

      it_behaves_like 'namespace with all CI minutes used' do
        let(:ci_minutes_used) { 2500 }
      end
    end

    context 'with a Group' do
      let!(:namespace) do
        create(:group, shared_runners_minutes_limit: 2000, extra_shared_runners_minutes_limit: extra_ci_minutes)
      end

      context 'with a single owner' do
        before do
          namespace.add_owner(user)
        end

        it_behaves_like 'namespace with available CI minutes' do
          let(:ci_minutes_used) { 1900 }
        end

        it_behaves_like 'namespace with all CI minutes used' do
          let(:ci_minutes_used) { 2500 }
        end

        context 'with extra CI minutes' do
          let(:extra_ci_minutes) { 1000 }

          it_behaves_like 'namespace with available CI minutes' do
            let(:ci_minutes_used) { 2500 }
          end

          it_behaves_like 'namespace with all CI minutes used' do
            let(:ci_minutes_used) { 3100 }
          end
        end
      end

      context 'with multiple owners' do
        before do
          namespace.add_owner(user)
          namespace.add_owner(user_2)
        end

        it_behaves_like 'namespace with available CI minutes' do
          let(:ci_minutes_used) { 1900 }
        end

        context 'when usage is over the quote' do
          let(:ci_minutes_used) { 2001 }

          it 'sends the email to all the owners' do
            expect(CiMinutesUsageMailer).to receive(:notify)
              .with(namespace, match_array([user_2.email, user.email]))
              .and_return(spy)

            subject
          end

          context 'when last_ci_minutes_notification_at has a value' do
            before do
              namespace.update_attribute(:last_ci_minutes_notification_at, Time.current)
            end

            it 'does not notify owners' do
              expect(CiMinutesUsageMailer).not_to receive(:notify)

              subject
            end
          end
        end
      end
    end
  end

  describe 'CI usage limit approaching' do
    let(:namespace) { create(:group, shared_runners_minutes_limit: 2000) }

    def notify_owners
      described_class.new(project).execute
    end

    shared_examples 'no notification is sent' do
      it 'does not notify owners' do
        expect(CiMinutesUsageMailer).not_to receive(:notify_limit)

        notify_owners
      end
    end

    shared_examples 'notification for custom level is sent' do |minutes_used, expected_level|
      before do
        namespace_statistics.update_attribute(:shared_runners_seconds, minutes_used * 60)
      end

      it 'notifies the the owners about it' do
        expect(CiMinutesUsageMailer).to receive(:notify_limit)
          .with(namespace, array_including(user_2.email, user.email), expected_level)
          .and_call_original

        notify_owners
      end
    end

    before do
      namespace.add_owner(user)
      namespace.add_owner(user_2)
    end

    context 'when available minutes are above notification levels' do
      let(:ci_minutes_used) { 1000 }

      it_behaves_like 'no notification is sent'
    end

    context 'when available minutes have reached the first level of alert' do
      context 'when quota is unlimited' do
        let(:ci_minutes_used) { 1500 }

        before do
          namespace.update_attribute(:shared_runners_minutes_limit, 0)
        end

        it_behaves_like 'no notification is sent'
      end

      it_behaves_like 'notification for custom level is sent', 1500, 30

      context 'when other Pipeline has finished but second level of alert has not been reached' do
        before do
          namespace_statistics.update_attribute(:shared_runners_seconds, 1500 * 60)
          notify_owners

          namespace_statistics.update_attribute(:shared_runners_seconds, 1600 * 60)
        end

        it_behaves_like 'no notification is sent'
      end
    end

    context 'when available minutes have reached the second level of alert' do
      it_behaves_like 'notification for custom level is sent', 1500, 30

      it_behaves_like 'notification for custom level is sent', 1980, 5
    end

    context 'when there are not available minutes to use' do
      include_examples 'no notification is sent'
    end
  end
end
