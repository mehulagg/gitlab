# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallSchedule do
  let_it_be_with_reload(:project) { create(:project) }

  describe '.associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:rotations).inverse_of(:schedule) }
    it { is_expected.to have_many(:participants).through(:rotations) }
  end

  describe '.validations' do
    let(:timezones) { ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.identifier } }
    let(:name) { 'Default on-call schedule' }

    subject { build(:incident_management_oncall_schedule, project: project, name: name) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }
    it { is_expected.to validate_presence_of(:timezone) }
    it { is_expected.to validate_inclusion_of(:timezone).in_array(timezones) }

    context 'when the oncall schedule with the same name exists' do
      before do
        create(:incident_management_oncall_schedule, project: project, name: name)
      end

      it 'has validation errors' do
        expect(subject).to be_invalid
        expect(subject.errors.full_messages.to_sentence).to eq('Name has already been taken')
      end
    end
  end

  describe 'scopes' do
    let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
    let_it_be(:other_schedule) { create(:incident_management_oncall_schedule) }

    describe '.for_project' do
      subject { described_class.for_project(project) }

      it { is_expected.to contain_exactly(schedule) }
    end
  end

  it_behaves_like 'AtomicInternalId' do
    let(:internal_id_attribute) { :iid }
    let(:instance) { build(:incident_management_oncall_schedule) }
    let(:scope) { :project }
    let(:scope_attrs) { { project: instance.project } }
    let(:usage) { :incident_management_oncall_schedules }
  end

  describe '.for_iid' do
    let_it_be(:oncall_schedule1) { create(:incident_management_oncall_schedule, project: project) }
    let_it_be(:oncall_schedule2) { create(:incident_management_oncall_schedule, project: project) }

    it 'returns only records with that IID' do
      expect(described_class.for_iid(oncall_schedule1.iid)).to contain_exactly(oncall_schedule1)
    end
  end

  describe '#backfill_escalation_policy' do
    subject(:schedule) { create(:incident_management_oncall_schedule, project: project) }

    context 'when the escalation policies feature is disabled' do
      before do
        stub_feature_flags(escalation_policies_mvc: false)
      end

      context 'with an existing escalation policy' do
        let_it_be(:policy) { create(:incident_management_escalation_policy, project: project) }
        let_it_be(:rule) { policy.rules.first }

        it 'creates an new escalation rule on the existing policy' do
          expect { schedule }
            .to change(::IncidentManagement::EscalationPolicy, :count).by(0)
            .and change(::IncidentManagement::EscalationRule, :count).by(1)

          expect(policy.reload.rules.length).to eq(2)
          expect(policy.rules.first).to eq(rule)
          expect(policy.rules.second).to have_attributes(
            elapsed_time_seconds: 0,
            oncall_schedule: schedule,
            status: 'acknowledged'
          )
        end
      end

      context 'without an existing escalation policy' do
        let(:policy) { ::IncidentManagement::EscalationPolicy.last! }

        it 'creates a new escalation policy and rule' do
          expect { schedule }
            .to change(::IncidentManagement::EscalationPolicy, :count).by(1)
            .and change(::IncidentManagement::EscalationRule, :count).by(1)

          expect(policy).to have_attributes(
            name: 'On-call Escalation Policy',
            description: "Immediately notify #{schedule.name}"
          )
          expect(policy.rules.length).to eq(1)
          expect(policy.rules.first).to have_attributes(
            elapsed_time_seconds: 0,
            oncall_schedule: schedule,
            status: 'acknowledged'
          )
        end

        context 'with a previously created schedule which has not yet been backfilled' do
          let_it_be(:existing_schedule) { create(:incident_management_oncall_schedule, project: project) }

          it 'creates an new escalation rule on the existing policy' do
            expect { schedule }
              .to change(::IncidentManagement::EscalationPolicy, :count).by(1)
              .and change(::IncidentManagement::EscalationRule, :count).by(2)

            expect(policy.rules.length).to eq(2)
            expect(policy.rules.first).to have_attributes(
              elapsed_time_seconds: 0,
              oncall_schedule: existing_schedule,
              status: 'acknowledged'
            )
            expect(policy.rules.second).to have_attributes(
              elapsed_time_seconds: 0,
              oncall_schedule: schedule,
              status: 'acknowledged'
            )
          end
        end
      end

      context 'when the backfill is disabled directly' do
        before do
          stub_feature_flags(escalation_policies_mvc: false, escalation_policies_backfill: false)
        end

        it 'does not alter the escalation policies' do
          expect { schedule }
            .to not_change(::IncidentManagement::EscalationPolicy, :count)
            .and not_change(::IncidentManagement::EscalationRule, :count)
        end
      end
    end

    context 'when the escalation policies feature is enabled' do
      it 'does not alter the escalation policies' do
        expect { schedule }
          .to not_change(::IncidentManagement::EscalationPolicy, :count)
          .and not_change(::IncidentManagement::EscalationRule, :count)
      end
    end
  end
end
