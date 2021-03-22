# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NotificationRecipient do
  let_it_be(:user) { create(:user) }
  let(:namespace) { create(:namespace, owner: user, emails_disabled: namespace_emails_disabled) }
  let(:project) { create(:project, namespace: namespace, emails_disabled: project_emails_disabled) }
  let(:target) { create(:issue, project: project) }
  let(:namespace_emails_disabled) { false }
  let(:project_emails_disabled) { false }

  subject(:recipient) { described_class.new(user, :watch, target: target, project: project) }

  describe '#notifiable?' do
    subject { described_class.new(user, type, target: target, project: project).notifiable? }

    context 'when type is mention' do
      let(:type) { :mention }

      context 'when emails are disabled at namespace level' do
        let(:namespace_emails_disabled) { true }

        it { is_expected.to be_falsey }
      end

      context 'when emails are disabled at project level' do
        let(:project_emails_disabled) { true }

        it { is_expected.to be_falsey }
      end

      context 'when emails are enabled at namespace level' do
        it { is_expected.to be_truthy }
      end

      context 'when emails are enabled at project level' do
        it { is_expected.to be_truthy }
      end
    end

    context 'when type is :subscription' do
      let(:type) { :subscription }

      context 'when user has no subscription to the target' do
        it { is_expected.to be_falsey }
      end

      context 'when user has a subscription to the target' do
        before do
          create(:subscription, project: project, user: user, subscribable: target, subscribed: subscription_state)
        end

        context 'when subscription "subscribed" is false' do
          let(:subscription_state) { false }

          it { is_expected.to be_falsey }
        end

        context 'when subscription "subscribed" is true' do
          let(:subscription_state) { true }

          it { is_expected.to be_truthy }
        end
      end
    end
  end

  describe '#has_access?' do
    before do
      allow(user).to receive(:can?).and_call_original
    end

    context 'user cannot read cross project' do
      it 'returns false' do
        expect(user).to receive(:can?).with(:read_cross_project).and_return(false)
        expect(recipient.has_access?).to eq false
      end
    end

    context 'user cannot read build' do
      let(:target) { build(:ci_pipeline) }

      it 'returns false' do
        expect(user).to receive(:can?).with(:read_build, target).and_return(false)
        expect(recipient.has_access?).to eq false
      end
    end

    context 'user cannot read commit' do
      let(:target) { build(:commit) }

      it 'returns false' do
        expect(user).to receive(:can?).with(:read_commit, target).and_return(false)
        expect(recipient.has_access?).to eq false
      end
    end

    context 'target has no policy' do
      let(:target) { double.as_null_object }

      it 'returns true' do
        expect(recipient.has_access?).to eq true
      end
    end
  end

  describe '#notification_setting' do
    context 'for child groups' do
      let!(:moved_group) { create(:group) }
      let(:group) { create(:group) }
      let(:sub_group_1) { create(:group, parent: group) }
      let(:sub_group_2) { create(:group, parent: sub_group_1) }
      let(:project) { create(:project, namespace: moved_group) }

      before do
        sub_group_2.add_owner(user)
        moved_group.add_owner(user)
        Groups::TransferService.new(moved_group, user).execute(sub_group_2)

        moved_group.reload
      end

      context 'when notification setting is global' do
        before do
          user.notification_settings_for(group).global!
          user.notification_settings_for(sub_group_1).mention!
          user.notification_settings_for(sub_group_2).global!
          user.notification_settings_for(moved_group).global!
        end

        it 'considers notification setting from the first parent without global setting' do
          expect(subject.notification_setting.source).to eq(sub_group_1)
        end
      end

      context 'when notification setting is not global' do
        before do
          user.notification_settings_for(group).global!
          user.notification_settings_for(sub_group_1).mention!
          user.notification_settings_for(sub_group_2).watch!
          user.notification_settings_for(moved_group).disabled!
        end

        it 'considers notification setting from lowest group member in hierarchy' do
          expect(subject.notification_setting.source).to eq(moved_group)
        end
      end
    end
  end

  describe '#suitable_notification_level?' do
    context 'when notification level is mention' do
      before do
        user.notification_settings_for(project).mention!
      end

      context 'when type is mention' do
        let(:recipient) { described_class.new(user, :mention, target: target, project: project) }

        it 'returns true' do
          expect(recipient.suitable_notification_level?).to eq true
        end
      end

      context 'when type is not mention' do
        it 'returns false' do
          expect(recipient.suitable_notification_level?).to eq false
        end
      end
    end

    context 'when notification level is participating' do
      let(:notification_setting) { user.notification_settings_for(project) }

      context 'when type is participating' do
        let(:recipient) { described_class.new(user, :participating, target: target, project: project) }

        it 'returns true' do
          expect(recipient.suitable_notification_level?).to eq true
        end
      end

      context 'when type is mention' do
        let(:recipient) { described_class.new(user, :mention, target: target, project: project) }

        it 'returns true' do
          expect(recipient.suitable_notification_level?).to eq true
        end
      end

      context 'with custom action' do
        context "when action is failed_pipeline" do
          let(:recipient) do
            described_class.new(
              user,
              :watch,
              custom_action: :failed_pipeline,
              target: target,
              project: project
            )
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context "when action is fixed_pipeline" do
          let(:recipient) do
            described_class.new(
              user,
              :watch,
              custom_action: :fixed_pipeline,
              target: target,
              project: project
            )
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context "when action is not fixed_pipeline or failed_pipeline" do
          let(:recipient) do
            described_class.new(
              user,
              :watch,
              custom_action: :success_pipeline,
              target: target,
              project: project
            )
          end

          it 'returns false' do
            expect(recipient.suitable_notification_level?).to eq false
          end
        end
      end
    end

    context 'when notification level is custom' do
      before do
        user.notification_settings_for(project).custom!
      end

      context 'when type is participating' do
        let(:notification_setting) { user.notification_settings_for(project) }
        let(:recipient) do
          described_class.new(
            user,
            :participating,
            custom_action: :new_note,
            target: target,
            project: project
          )
        end

        context 'with custom event enabled' do
          before do
            notification_setting.update!(new_note: true)
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context 'without custom event enabled' do
          before do
            notification_setting.update!(new_note: false)
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end
      end

      context 'when type is mention' do
        let(:notification_setting) { user.notification_settings_for(project) }
        let(:recipient) do
          described_class.new(
            user,
            :mention,
            custom_action: :new_issue,
            target: target,
            project: project
          )
        end

        context 'with custom event enabled' do
          before do
            notification_setting.update!(new_issue: true)
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context 'without custom event enabled' do
          before do
            notification_setting.update!(new_issue: false)
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end
      end

      context 'when type is watch' do
        let(:notification_setting) { user.notification_settings_for(project) }
        let(:recipient) do
          described_class.new(
            user,
            :watch,
            custom_action: :failed_pipeline,
            target: target,
            project: project
          )
        end

        context 'with custom event enabled' do
          before do
            notification_setting.update!(failed_pipeline: true)
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context 'without custom event enabled' do
          before do
            notification_setting.update!(failed_pipeline: false)
          end

          it 'returns false' do
            expect(recipient.suitable_notification_level?).to eq false
          end
        end

        context 'when custom_action is fixed_pipeline and success_pipeline event is enabled' do
          let(:recipient) do
            described_class.new(
              user,
              :watch,
              custom_action: :fixed_pipeline,
              target: target,
              project: project
            )
          end

          before do
            notification_setting.update!(success_pipeline: true)
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context 'with merge_when_pipeline_succeeds' do
          let(:notification_setting) { user.notification_settings_for(project) }
          let(:recipient) do
            described_class.new(
              user,
              :watch,
              custom_action: :merge_when_pipeline_succeeds,
              target: target,
              project: project
            )
          end

          context 'custom event enabled' do
            before do
              notification_setting.update!(merge_when_pipeline_succeeds: true)
            end

            it 'returns true' do
              expect(recipient.suitable_notification_level?).to eq true
            end
          end

          context 'custom event disabled' do
            before do
              notification_setting.update!(merge_when_pipeline_succeeds: false)
            end

            it 'returns false' do
              expect(recipient.suitable_notification_level?).to eq false
            end
          end
        end
      end
    end

    context 'when notification level is watch' do
      before do
        user.notification_settings_for(project).watch!
      end

      context 'when type is watch' do
        context 'without excluded watcher events' do
          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context 'with excluded watcher events' do
          let(:recipient) do
            described_class.new(user, :watch, custom_action: :issue_due, target: target, project: project)
          end

          it 'returns false' do
            expect(recipient.suitable_notification_level?).to eq false
          end
        end
      end

      context 'when type is not watch' do
        context 'without excluded watcher events' do
          let(:recipient) { described_class.new(user, :participating, target: target, project: project) }

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end

        context 'with excluded watcher events' do
          let(:recipient) do
            described_class.new(user, :participating, custom_action: :issue_due, target: target, project: project)
          end

          it 'returns true' do
            expect(recipient.suitable_notification_level?).to eq true
          end
        end
      end
    end
  end
end
