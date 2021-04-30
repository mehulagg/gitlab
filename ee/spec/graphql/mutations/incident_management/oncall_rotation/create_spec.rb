# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::IncidentManagement::OncallRotation::Create do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }

  let(:args) do
    {
      project_path: project.full_path,
      name: 'On-call rotation',
      schedule_iid: schedule.iid,
      starts_at: "2020-01-10 09:00".in_time_zone(schedule.timezone),
      rotation_length: {
        length: 1,
        unit: ::IncidentManagement::OncallRotation.length_units[:days]
      },
      participants: [
        {
          username: current_user.username,
          color_weight: ::IncidentManagement::OncallParticipant.color_weights['50'],
          color_palette: ::IncidentManagement::OncallParticipant.color_palettes[:blue]
        }
      ]
    }
  end

  describe '#resolve' do
    subject(:resolve) { mutation_for(project, current_user).resolve(iid: schedule.iid, project_path: project.full_path, participants: args[:participants], **args) }

    context 'user has access to project' do
      before do
        stub_licensed_features(oncall_schedules: true)
        project.add_maintainer(current_user)
      end

      context 'when OncallRotation::CreateService responds with success' do
        it 'returns the on-call rotation with no errors' do
          expect(resolve).to match(
            oncall_rotation: ::IncidentManagement::OncallRotation.last!,
            errors: be_empty
          )
        end

        context 'with endsAt arg' do
          let(:ends_at) { "2020-02-10 09:00".in_time_zone(schedule.timezone) }

          before do
            args.merge!(ends_at: ends_at)
          end

          it 'returns the on-call rotation with no errors' do
            expect(resolve[:oncall_rotation].ends_at).to eq(ends_at)
            expect(resolve[:errors]).to be_empty
          end

          context 'when endsAt is nil' do
            let(:ends_at) { nil }

            it 'returns the on-call rotation with no errors' do
              expect(resolve[:oncall_rotation].ends_at).to be_nil
              expect(resolve[:errors]).to be_empty
            end
          end
        end
      end

      context 'when OncallRotations::CreateService responds with an error' do
        before do
          allow_next_instance_of(::IncidentManagement::OncallRotations::CreateService) do |service|
            allow(service).to receive(:execute)
              .and_return(ServiceResponse.error(payload: { oncall_rotation: nil }, message: 'An on-call rotation already exists'))
          end
        end

        it 'returns errors' do
          expect(resolve).to eq(
            oncall_rotation: nil,
            errors: ['An on-call rotation already exists']
          )
        end
      end

      context 'with active period times given' do
        let(:start_time) { '08:00' }
        let(:end_time) { '17:00' }

        before do
          args[:active_period] = {
            start_time: start_time,
            end_time: end_time
          }
        end

        it 'returns the on-call rotation with no errors' do
          expect(resolve).to match(
            oncall_rotation: ::IncidentManagement::OncallRotation.last!,
            errors: be_empty
          )
        end

        it 'saves the on-call rotation with active period times' do
          rotation = resolve[:oncall_rotation]

          expect(rotation.active_period_start.strftime('%H:%M')).to eql('08:00')
          expect(rotation.active_period_end.strftime('%H:%M')).to eql('17:00')
        end

        context 'hours rotation length unit' do
          before do
            args[:rotation_length][:unit] = ::IncidentManagement::OncallRotation.length_units[:hours]
          end

          it 'returns errors' do
            expect(resolve).to match(
              oncall_rotation: nil,
              errors: [/Restricted shift times are not available for hourly shifts/]
            )
          end
        end

        context 'end time is before start time' do
          let(:start_time) { '17:00' }
          let(:end_time) { '08:00' }

          it 'saves the on-call rotation with active period times' do
            rotation = resolve[:oncall_rotation]

            expect(rotation.active_period_start.strftime('%H:%M')).to eql('17:00')
            expect(rotation.active_period_end.strftime('%H:%M')).to eql('08:00')
          end
        end

        context 'invalid time given' do
          let(:start_time) {  'an invalid time' }

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'Time given is invalid')
          end
        end
      end

      describe 'error cases' do
        context 'user cannot be found' do
          before do
            args.merge!(participants: [username: 'unknown'])
          end

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, "A provided username couldn't be matched to a user")
          end
        end

        context 'project path incorrect' do
          before do
            args[:project_path] = "something/incorrect"
          end

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'The project could not be found')
          end
        end

        context 'duplicate participants' do
          before do
            args[:participants] << args[:participants].first
          end

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'A duplicate username is included in the participant list')
          end
        end

        context 'schedule does not exist' do
          let(:schedule) { double(iid: non_existing_record_iid, timezone: 'UTC') }

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'The schedule could not be found')
          end
        end

        context 'too many users' do
          before do
            stub_const('Mutations::IncidentManagement::OncallRotation::Base::MAXIMUM_PARTICIPANTS', 0)
          end

          it 'raises an error' do
            expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, "A maximum of #{described_class::MAXIMUM_PARTICIPANTS} participants can be added")
          end
        end
      end
    end

    context 'when resource is not accessible to the user' do
      it 'raises an error' do
        expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ArgumentError, 'The schedule could not be found')
      end
    end
  end

  private

  def mutation_for(project, user)
    described_class.new(object: project, context: { current_user: user }, field: nil)
  end
end
