# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotations::PreviewService do
  let_it_be_with_refind(:project) { create(:project) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:user_with_permissions) { create(:user) }
  let_it_be(:user_without_permissions) { create(:user) }
  let_it_be(:current_user) { user_with_permissions }
  let_it_be(:starts_at) { Time.current.change(usec: 0) }

  let(:participants) do
    [
      {
        user: current_user,
        color_palette: 'blue',
        color_weight: '500'
      }
    ]
  end

  let(:params) { { name: 'On-call rotation', starts_at: starts_at, ends_at: 1.month.after(starts_at), length: '1', length_unit: 'days' }.merge(participants: participants) }
  let(:service) { described_class.new(schedule, project, current_user, params) }

  before_all do
    project.add_maintainer(user_with_permissions)
  end

  before do
    stub_licensed_features(oncall_schedules: true)
  end

  describe '#execute' do
    shared_examples 'error response' do |message|
      it 'does not save the rotation and has an informative message' do
        expect { execute }.not_to change(IncidentManagement::OncallRotation, :count)
        expect(execute).to be_error
        expect(execute.message).to eq(message)
      end
    end

    shared_examples 'successfully generates rotation' do
      it 'successfully generates an on-call rotation with participants' do
        expect { execute }.not_to change(IncidentManagement::OncallRotation, :count)
        expect(execute).to be_success

        oncall_rotation = execute.payload[:oncall_rotation]
        expect(oncall_rotation).to be_a(::IncidentManagement::OncallRotation)
        expect(oncall_rotation).not_to be_persisted
        expect(oncall_rotation.name).to eq('On-call rotation - Preview')
        expect(oncall_rotation.starts_at).to eq(starts_at)
        expect(oncall_rotation.ends_at).to eq(1.month.after(starts_at))
        expect(oncall_rotation.length).to eq(1)
        expect(oncall_rotation.length_unit).to eq('days')

        expect(oncall_rotation.participants.length).to eq(1)
        expect(oncall_rotation.participants.first).to have_attributes(
          **participants.first,
          rotation: oncall_rotation,
          persisted?: false
        )
      end
    end

    subject(:execute) { service.execute }

    it_behaves_like 'successfully generates rotation'
    include_examples 'permissions errors for oncall schedules', 'You have insufficient permissions to preview an on-call rotation for this project'
    include_examples 'feature availability error for oncall schedules'
    include_examples 'participants errors for oncall rotation'

    context 'with an active period given' do
      include_context 'with active period params for new rotation'

      it_behaves_like 'successfully generates rotation'
      include_examples 'parses the active period times'
      include_examples 'active period errors for an oncall rotation'
    end
  end
end
