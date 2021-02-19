# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::RunnersHelper do
  context "with pipeline minutes notifications" do
    let_it_be(:user) { create(:user) }
    let_it_be(:namespace) { create(:namespace, owner: user) }
    let_it_be(:project) { create(:project, namespace: namespace) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    shared_examples_for 'minutes notification' do
      let(:show_warning) { true }
      let(:context_level) { project }
      let(:threshold) { double('Ci::Minutes::Notification', show?: show_warning) }

      before do
        allow(::Ci::Minutes::Notification).to receive(:new).and_return(threshold)
      end

      context 'with a project and namespace' do
        context 'when not on dot com' do
          let(:dev_env_or_com) { false }

          it { is_expected.to be_falsey }
        end

        context 'when on dot com' do
          it { is_expected.to be_truthy }

          context 'without a persisted project passed' do
            let(:project) { build(:project) }
            let(:context_level) { namespace }

            it { is_expected.to be_truthy }
          end

          context 'without a persisted namespace passed' do
            let(:namespace) { build(:namespace) }

            it { is_expected.to be_truthy }
          end

          context 'with neither a project nor a namespace' do
            let(:project) { build(:project) }
            let(:namespace) { build(:namespace) }

            it { is_expected.to be_falsey }

            context 'when show_pipeline_minutes_notification_dot? has been called before' do
              it 'does not do all the notification and query work again' do
                expect(threshold).not_to receive(:show?)
                expect(project).to receive(:persisted?).once

                helper.show_pipeline_minutes_notification_dot?(project, namespace)

                expect(subject).to be_falsey
              end
            end
          end

          context 'when show notification is falsey' do
            let(:show_warning) { false }

            it { is_expected.to be_falsey }
          end

          context 'when show_pipeline_minutes_notification_dot? has been called before' do
            it 'does not do all the notification and query work again' do
              expect(threshold).to receive(:show?).once
              expect(project).to receive(:persisted?).once

              helper.show_pipeline_minutes_notification_dot?(project, namespace)

              expect(subject).to be_truthy
            end
          end
        end
      end
    end

    context 'with notifications' do
      let(:dev_env_or_com) { true }

      describe '.show_buy_pipeline_minutes?' do
        subject { helper.show_buy_pipeline_minutes?(project, namespace) }

        context 'when on dot com' do
          it_behaves_like 'minutes notification' do
            before do
              allow(::Gitlab).to receive(:dev_env_or_com?).and_return(dev_env_or_com)
            end
          end
        end
      end

      describe '.show_pipeline_minutes_notification_dot?' do
        subject { helper.show_pipeline_minutes_notification_dot?(project, namespace) }

        before do
          allow(::Gitlab).to receive(:dev_env_or_com?).and_return(dev_env_or_com)
        end

        it_behaves_like 'minutes notification'

        context 'when the notification dot has been acknowledged' do
          before do
            create(:user_callout, user: user, feature_name: described_class::BUY_PIPELINE_MINUTES_NOTIFICATION_DOT)
            expect(helper).not_to receive(:show_out_of_pipeline_minutes_notification?)
          end

          it { is_expected.to be_falsy }
        end

        context 'when the notification dot has not been acknowledged' do
          before do
            expect(helper).to receive(:show_out_of_pipeline_minutes_notification?).and_return(true)
          end

          it { is_expected.to be_truthy }
        end
      end

      describe '.show_buy_pipeline_with_subtext?' do
        subject { helper.show_buy_pipeline_with_subtext?(project, namespace) }

        before do
          allow(::Gitlab).to receive(:dev_env_or_com?).and_return(dev_env_or_com)
        end

        context 'when the notification dot has not been acknowledged' do
          before do
            expect(helper).not_to receive(:show_out_of_pipeline_minutes_notification?)
          end

          it { is_expected.to be_falsey }
        end

        context 'when the notification dot has been acknowledged' do
          before do
            create(:user_callout, user: user, feature_name: described_class::BUY_PIPELINE_MINUTES_NOTIFICATION_DOT)
            expect(helper).to receive(:show_out_of_pipeline_minutes_notification?).and_return(true)
          end

          it { is_expected.to be_truthy }
        end
      end

      describe '.root_ancestor_namespace' do
        subject(:root_ancestor) { helper.root_ancestor_namespace(project, namespace) }

        context 'with a project' do
          it 'returns the project root ancestor' do
            expect(root_ancestor).to eq project.root_ancestor
          end
        end

        context 'with only a namespace' do
          let(:project) { nil }

          it 'returns the namespace root ancestor' do
            expect(root_ancestor).to eq namespace.root_ancestor
          end
        end
      end
    end
  end

  describe "#runner_status_icon" do
    it "returns - not contacted yet" do
      runner = build :ci_runner
      expect(runner_status_icon(runner)).to include("not connected yet")
    end

    it "returns offline text" do
      runner = build(:ci_runner, contacted_at: 1.day.ago, active: true)
      expect(runner_status_icon(runner)).to include("Runner is offline")
    end

    it "returns online text" do
      runner = build(:ci_runner, contacted_at: 1.second.ago, active: true)
      expect(runner_status_icon(runner)).to include("Runner is online")
    end
  end

  describe '#runner_contacted_at' do
    let(:contacted_at_stored) { 1.hour.ago.change(usec: 0) }
    let(:contacted_at_cached) { 1.second.ago.change(usec: 0) }
    let(:runner) { create(:ci_runner, contacted_at: contacted_at_stored) }

    before do
      runner.cache_attributes(contacted_at: contacted_at_cached)
    end

    context 'without sorting' do
      it 'returns cached value' do
        expect(runner_contacted_at(runner)).to eq(contacted_at_cached)
      end
    end

    context 'with sorting set to created_date' do
      before do
        controller.params[:sort] = 'created_date'
      end

      it 'returns cached value' do
        expect(runner_contacted_at(runner)).to eq(contacted_at_cached)
      end
    end

    context 'with sorting set to contacted_asc' do
      before do
        controller.params[:sort] = 'contacted_asc'
      end

      it 'returns stored value' do
        expect(runner_contacted_at(runner)).to eq(contacted_at_stored)
      end
    end
  end

  describe '#group_shared_runners_settings_data' do
    let(:group) { create(:group, parent: parent, shared_runners_enabled: false) }
    let(:parent) { create(:group) }

    it 'returns group data for top level group' do
      data = group_shared_runners_settings_data(parent)

      expect(data[:update_path]).to eq("/api/v4/groups/#{parent.id}")
      expect(data[:shared_runners_availability]).to eq('enabled')
      expect(data[:parent_shared_runners_availability]).to eq(nil)
    end

    it 'returns group data for child group' do
      data = group_shared_runners_settings_data(group)

      expect(data[:update_path]).to eq("/api/v4/groups/#{group.id}")
      expect(data[:shared_runners_availability]).to eq('disabled_and_unoverridable')
      expect(data[:parent_shared_runners_availability]).to eq('enabled')
    end
  end

  describe '#toggle_shared_runners_settings_data' do
    let_it_be(:group) { create(:group) }
    let(:project_with_runners) { create(:project, namespace: group, shared_runners_enabled: true) }
    let(:project_without_runners) { create(:project, namespace: group, shared_runners_enabled: false) }

    context 'when project has runners' do
      it 'returns the correct value for is_enabled' do
        data = toggle_shared_runners_settings_data(project_with_runners)
        expect(data[:is_enabled]).to eq("true")
      end
    end

    context 'when project does not have runners' do
      it 'returns the correct value for is_enabled' do
        data = toggle_shared_runners_settings_data(project_without_runners)
        expect(data[:is_enabled]).to eq("false")
      end
    end

    context 'for all projects' do
      it 'returns the update path for toggling the shared runners setting' do
        data = toggle_shared_runners_settings_data(project_with_runners)
        expect(data[:update_path]).to eq(toggle_shared_runners_project_runners_path(project_with_runners))
      end

      it 'returns false for is_disabled_and_unoverridable when project has no group' do
        project = create(:project)

        data = toggle_shared_runners_settings_data(project)
        expect(data[:is_disabled_and_unoverridable]).to eq("false")
      end

      using RSpec::Parameterized::TableSyntax

      where(:shared_runners_setting, :is_disabled_and_unoverridable) do
        'enabled'                    | "false"
        'disabled_with_override'     | "false"
        'disabled_and_unoverridable' | "true"
      end

      with_them do
        it 'returns the override runner status for project with group' do
          group = create(:group)
          project = create(:project, group: group)
          allow(group).to receive(:shared_runners_setting).and_return(shared_runners_setting)

          data = toggle_shared_runners_settings_data(project)
          expect(data[:is_disabled_and_unoverridable]).to eq(is_disabled_and_unoverridable)
        end
      end
    end
  end
end
