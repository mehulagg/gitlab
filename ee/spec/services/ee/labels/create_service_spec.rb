# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Labels::CreateService do
  include AfterNextHelpers

  describe '#execute' do
    let(:params) do
      {
        title: title,
        color: '#000000'
      }
    end

    context 'in a project' do
      subject(:execute) { described_class.new(params).execute(project: project) }

      let(:project) { create(:project) }

      context 'with scoped labels' do
        let(:title) { 'scoped::label' }

        it 'records a namespace onboarding progress action' do
          expect_next(OnboardingProgressService, project.group)
            .to receive(:execute).with(action: :scoped_label_created).and_call_original

          execute
        end
      end

      context 'with not scoped labels' do
        let(:title) { 'some label' }

        it 'does not record a namespace onboarding progress action' do
          expect(OnboardingProgressService).not_to receive(:new)

          execute
        end
      end

      context 'without a project' do
        let(:title) { 'scoped::label' }
        let(:project) { nil }

        it 'does not record a namespace onboarding progress action' do
          expect(OnboardingProgressService).not_to receive(:new)

          execute
        end
      end
    end

    context 'in a group' do
      subject(:execute) { described_class.new(params).execute(group: group) }

      let(:group) { create(:group) }

      context 'with scoped labels' do
        let(:title) { 'scoped::label' }

        it 'records a namespace onboarding progress action' do
          expect_next(OnboardingProgressService, group)
            .to receive(:execute).with(action: :scoped_label_created).and_call_original

          execute
        end
      end

      context 'with not scoped labels' do
        let(:title) { 'some label' }

        it 'does not record a namespace onboarding progress action' do
          expect(OnboardingProgressService).not_to receive(:new)

          execute
        end
      end

      context 'without a group' do
        let(:title) { 'scoped::label' }
        let(:group) { nil }

        it 'does not record a namespace onboarding progress action' do
          expect(OnboardingProgressService).not_to receive(:new)

          execute
        end
      end
    end
  end
end
