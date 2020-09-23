# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::DestroyService do
  let(:current_user) { create(:admin) }

  subject(:service) { described_class.new(current_user) }

  describe '#execute' do
    let(:user) { create(:user) }

    subject(:operation) { service.execute(user) }

    it 'returns result' do
      allow(user).to receive(:destroy).and_return(user)

      expect(operation).to eq(user)
    end

    context 'when project is a mirror' do
      let(:project) { create(:project, :mirror, mirror_user_id: user.id) }

      it 'disables mirror and does not assign a new mirror_user' do
        expect(::Gitlab::ErrorTracking).to receive(:track_exception)

        allow_next_instance_of(::NotificationService) do |notification|
          expect(notification).to receive(:mirror_was_disabled)
            .with(project, user.name)
            .and_call_original
        end

        expect { operation }.to change { project.reload.mirror_user }.from(user).to(nil)
          .and change { project.reload.mirror }.from(true).to(false)
      end
    end

    describe 'audit events' do
      include_examples 'audit event logging' do
        let(:fail_condition!) do
          expect_any_instance_of(User)
            .to receive(:destroy).and_return(false)
        end

        let(:attributes) do
          {
            author_id: current_user.id,
            entity_id: @resource.id,
            entity_type: 'User',
            details: {
              remove: 'user',
              author_name: current_user.name,
              target_id: @resource.full_path,
              target_type: 'User',
              target_details: @resource.full_path
            }
          }
        end
      end
    end
  end
end
