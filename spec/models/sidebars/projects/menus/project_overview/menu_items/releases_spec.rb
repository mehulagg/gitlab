# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::ProjectOverview::MenuItems::Releases, let_it_be_light_freeze: false do
  let_it_be(:project) { create(:project, :repository) }

  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  subject { described_class.new(context) }

  describe '#render?' do
    context 'when project repository is empty' do
      it 'returns false' do
        allow(project).to receive(:empty_repo?).and_return(true)

        expect(subject.render?).to eq false
      end
    end

    context 'when project repository is not empty' do
      context 'when user can read releases' do
        it 'returns true' do
          expect(subject.render?).to eq true
        end
      end

      context 'when user cannot read releases' do
        let(:user) { nil }

        it 'returns false' do
          expect(subject.render?).to eq false
        end
      end
    end
  end
end
