# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::LearnGitlab::Menu do
  let(:project) { build(:project) }
  let(:context) { Sidebars::Projects::Context.new(current_user: nil, container: project, learn_gitlab_experiment_enabled: experiment_enabled) }

  subject { described_class.new(context) }

  describe '#render?' do
    context 'when learn gitlab experiment is enabled' do
      let(:experiment_enabled) { true }

      it 'returns true' do
        expect(subject.render?).to eq true
      end
    end

    context 'when learn gitlab experiment is disabled' do
      let(:experiment_enabled) { false }

      it 'returns false' do
        expect(subject.render?).to eq false
      end
    end
  end
end
