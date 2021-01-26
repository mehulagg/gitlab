# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::ValueStreams::UpdateService do
  let_it_be(:user) { create(:user) }
  let_it_be(:group, refind: true) { create(:group) }

  let(:params) { {} }

  let(:value_stream) do
    create(:cycle_analytics_group_value_stream, name: 'VS 1', group: group, stages: [
      build(:cycle_analytics_group_stage, group: group, name: 'stage 1', custom: true),
      build(:cycle_analytics_group_stage, group: group, name: 'stage 2', custom: true)
    ])
  end

  let(:first_stage) { value_stream.stages.first }
  let(:last_stage) { value_stream.stages.last }

  subject { described_class.new(value_stream: value_stream, group: group, params: params, current_user: user).execute }

  it_behaves_like 'common value stream service examples'

  context 'when the feature is available' do
    before do
      group.add_developer(user)
      stub_licensed_features(cycle_analytics_for_groups: true)
    end

    context 'when empty stages are given' do
      let(:params) { { name: 'VS 1', stages: [] } }

      it 'removes the stages' do
        expect(subject).to be_success
        expect(subject.payload[:value_stream].reload.stages).to be_empty
      end
    end

    context 'updating one stage within a value stream' do
      let(:params) do
        {
          name: 'VS 1',
          stages: [
            { id: first_stage.id, name: first_stage.name, custom: true },
            { id: last_stage.id, name: 'updated', custom: true }
          ]
        }
      end

      it 'updates the stage' do
        expect(subject).to be_success
        expect(last_stage.reload.name).to eq('updated')
      end

      context 'when the params are invalid' do
        before do
          params[:stages].last[:name] = ''
        end

        it 'returns error' do
          expect(subject).to be_error
          errors = subject.payload[:errors].details
          expect(errors[:'stages[1].name']).to eq([{ error: :blank }])
        end
      end
    end

    context 'adding a new stage within a value stream' do
      let(:params) do
        {
          name: 'VS 1',
          stages: [
            { id: first_stage.id, name: first_stage.name, custom: true },
            { id: last_stage.id, name: last_stage.name, custom: true },
            { name: 'new stage', custom: true, start_event_identifier: 'merge_request_created', end_event_identifier: 'merge_request_closed' }
          ]
        }
      end

      it 'creates the stage' do
        expect(subject).to be_success
        expect(subject.payload[:value_stream].stages.last.name).to eq('new stage')
      end
    end

    context 'when adding a default stage' do
      let(:params) do
        {
          name: 'VS 1',
          stages: [
            { id: first_stage.id, name: first_stage.name, custom: true },
            { id: last_stage.id, name: last_stage.name, custom: true },
            { name: 'plan', custom: false }
          ]
        }
      end

      it 'creates the stage' do
        expect(subject).to be_success
        expect(subject.payload[:value_stream].stages.last.name).to eq('plan')
      end
    end
  end
end
