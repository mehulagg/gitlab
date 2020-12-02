# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContainerExpirationPolicies::TrackingService do
  let_it_be_with_reload(:repository) { create(:container_repository, :cleanup_scheduled) }

  let(:service) { described_class.new(repository) }
  let(:action) { :start }

  describe '#execute' do
    subject { service.execute(action) }

    ContainerExpirationPolicies::TrackingService::VALID_ACTIONS.each do |action|
      context "for action #{action}" do
        let(:action) { action }

        it 'tracks the action' do
          create_event_service_params = [
            nil,
            :worker,
            event_name: ContainerExpirationPolicies::TrackingService::PACKAGE_EVENT_NAMES[action],
            scope: :container
          ]

          expect(::Packages::CreateEventService)
            .to receive(:new).with(*create_event_service_params).and_call_original
          expect(::Gitlab::Tracking)
            .to receive(:event).with(described_class.name, action.to_s)

          subject
        end

        it 'updates the container repository' do
          expected_cleanup_status = case action
                                    when :start
                                      'cleanup_ongoing'
                                    when :stop
                                      'cleanup_unfinished'
                                    when :end
                                      'cleanup_unscheduled'
                                    end

          expect { subject }.to change { repository.expiration_policy_cleanup_status }.to(expected_cleanup_status)

          if action == :start
            expect(repository.expiration_policy_started_at).not_to be_nil
          else
            expect(repository.expiration_policy_started_at).to be_nil
          end
        end
      end
    end

    context 'without container repository' do
      let(:service) { described_class.new(nil) }

      it 'raises an error' do
        expect { subject }.to raise_error(ArgumentError, 'invalid container repository')
      end
    end
  end
end
