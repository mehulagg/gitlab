# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iterations::Cadences::CreateIterationsInAdvanceService do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:inactive_cadence) { create(:iterations_cadence, group: group, active: false, automatic: true, start_date: 2.weeks.ago) }
  let_it_be(:automated_cadence) { create(:iterations_cadence, group: group, active: true, automatic: true, start_date: 2.weeks.ago) }
  let_it_be(:manual_cadence) { create(:iterations_cadence, group: group, active: true, automatic: false, start_date: 2.weeks.ago) }

  subject { described_class.new(user, cadence).execute }

  describe '#execute' do
    context 'when user has permissions to create iterations' do
      context 'when user is a group developer' do
        before do
          group.add_developer(user)
        end

        context 'with nil cadence' do
          let(:cadence) { nil }

          it 'returns error' do
            expect(subject).to be_error
          end
        end

        context 'with manual cadence' do
          let(:cadence) { manual_cadence }

          it 'returns error' do
            expect(subject).to be_error
          end
        end

        context 'with inactive cadence' do
          let(:cadence) { inactive_cadence }

          it 'returns error' do
            expect(subject).to be_error
          end
        end

        context 'with automatic and active cadence' do
          let(:cadence) { automated_cadence }

          it 'does not return error' do
            expect(subject).not_to be_error
          end

          context 'when no iterations need to be created' do
            let_it_be(:iteration) { create(:iteration, group: group, iterations_cadence: automated_cadence, start_date: 1.week.from_now, due_date: 2.weeks.from_now)}

            it 'does not create any new iterations' do
              expect { subject }.not_to change(Iteration, :count)
            end
          end

          context 'when new iterations need to be created' do
            context 'when no iterations exist' do
              it 'creates new iterations' do
                expect { subject }.to change(Iteration, :count).by(3)
              end
            end

            context 'when advanced iterations exist but cadence needs to create more' do
              let_it_be(:current_iteration) { create(:iteration, group: group, iterations_cadence: automated_cadence, start_date: 3.days.ago, due_date: (1.week - 3.days).from_now)}
              let_it_be(:next_iteration) { create(:iteration, group: group, iterations_cadence: automated_cadence, start_date: current_iteration.due_date + 1.day, due_date: current_iteration.due_date + 1.week)}

              before do
                automated_cadence.iterations_in_advance = 2
              end

              it 'creates new iterations' do
                expect { subject }.to change(Iteration, :count).by(1)
              end
            end

            context 'when cadence has iterations but all are in the past' do
              let_it_be(:past_iteration1) { create(:iteration, group: group, title: 'Iteration 1', iterations_cadence: automated_cadence, start_date: 3.weeks.ago, due_date: 2.weeks.ago)}
              let_it_be(:past_iteration2) { create(:iteration, group: group, title: 'Iteration 2', iterations_cadence: automated_cadence, start_date: past_iteration1.due_date + 1.day, due_date: past_iteration1.due_date + 1.week)}

              before do
                automated_cadence.iterations_in_advance = 2
              end

              it 'creates new iterations' do
                # because last iteration ended 1 week ago, we generate one iteration for current week and 2 in advance
                expect { subject }.to change(Iteration, :count).by(3)
              end

              it 'sets the titles correctly based on iterations count and follow-up dates' do
                subject

                initial_start_date = past_iteration2.due_date + 1.day
                initial_due_date = past_iteration2.due_date + 1.week

                expect(group.reload.iterations.pluck(:title)).to eq([
                  'Iteration 1',
                  'Iteration 2',
                  "Iteration 3: #{(initial_start_date).strftime(Date::DATE_FORMATS[:long])} - #{initial_due_date.strftime(Date::DATE_FORMATS[:long])}",
                  "Iteration 4: #{(initial_due_date + 1.day).strftime(Date::DATE_FORMATS[:long])} - #{(initial_due_date + 1.week).strftime(Date::DATE_FORMATS[:long])}",
                  "Iteration 5: #{(initial_due_date + 1.week + 1.day).strftime(Date::DATE_FORMATS[:long])} - #{(initial_due_date + 2.weeks).strftime(Date::DATE_FORMATS[:long])}",
                ])
              end
            end
          end
        end
      end
    end
  end
end
