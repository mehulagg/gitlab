# frozen_string_literal: true

RSpec.shared_context 'with active period params for new rotation' do
  let(:active_period_start) { '08:00' }
  let(:active_period_end) { '17:00' }

  before do
    params[:active_period_start] = active_period_start
    params[:active_period_end] = active_period_end
  end

  shared_examples 'parses the active period times' do
    it 'includes the correct active period times' do
      oncall_rotation = execute.payload[:oncall_rotation]

      expect(oncall_rotation.active_period_start.strftime('%H:%M')).to eq(active_period_start)
      expect(oncall_rotation.active_period_end.strftime('%H:%M')).to eq(active_period_end)
    end
  end
end

RSpec.shared_examples 'permissions errors for oncall schedules' do |message|
  context 'when the current_user does not have permissions for on-call schedules' do
    let(:current_user) { user_without_permissions }

    it_behaves_like 'error response', message
  end

  context 'when the current_user is anonymous' do
    let(:current_user) { nil }

    it_behaves_like 'error response', message
  end
end

RSpec.shared_examples 'feature availability error for oncall schedules' do
  context 'when feature is not available' do
    before do
      stub_licensed_features(oncall_schedules: false)
    end

    it_behaves_like 'error response', 'Your license does not support on-call rotations'
  end
end

RSpec.shared_examples 'participants errors for oncall rotation' do
  context 'when too many participants' do
    before do
      stub_const('IncidentManagement::OncallRotations::SharedRotationLogic::MAXIMUM_PARTICIPANTS', 0)
    end

    it 'has an informative error message' do
      expect(execute).to be_error
      expect(execute.message).to eq("A maximum of #{IncidentManagement::OncallRotations::SharedRotationLogic::MAXIMUM_PARTICIPANTS} participants can be added")
    end
  end

  context 'when participant cannot read project' do
    let_it_be(:other_user) { create(:user) }

    let(:participants) do
      [
        {
          user: other_user,
          color_palette: 'blue',
          color_weight: '500'
        }
      ]
    end

    it_behaves_like 'error response', 'A participant has insufficient permissions to access the project'
  end

  context 'participant is included multiple times' do
    let(:participants) do
      [
        {
          user: current_user,
          color_palette: 'blue',
          color_weight: '500'
        },
        {
          user: current_user,
          color_palette: 'magenta',
          color_weight: '500'
        }
      ]
    end

    it_behaves_like 'error response', 'A user can only participate in a rotation once'
  end
end

RSpec.shared_examples 'active period errors for an oncall rotation' do
  context 'when only active period end time is set' do
    let(:active_period_start) { nil }

    it_behaves_like 'error response', "Active period start can't be blank"
  end

  context 'when only active period start time is set' do
    let(:active_period_end) { nil }

    it_behaves_like 'error response', "Active period end can't be blank"
  end

  context 'when end active time is before start active time' do
    let(:active_period_start) { '17:00' }
    let(:active_period_end) { '08:00' }

    it_behaves_like 'error response', "Active period end must be later than active period start"
  end
end
