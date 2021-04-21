# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::ProjectOverviewMenu do
  let_it_be(:project) { create(:project, :repository) }

  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  subject { described_class.new(context) }

  describe 'Releases' do
    context 'when project repository is empty' do
      it 'does not include releases menu item' do
        allow(project).to receive(:empty_repo?).and_return(true)

        expect(subject.items.index { |e| e.item_id == :releases}).to be_nil
      end
    end

    context 'when project repository is not empty' do
      context 'when user can download code' do
        it 'includes releases menu item' do
          expect(subject.items.index { |e| e.item_id == :releases}).to be_present
        end
      end

      context 'when user cannot download code' do
        let(:user) { nil }

        it 'does not include releases menu item' do
          expect(subject.items.index { |e| e.item_id == :releases}).to be_nil
        end
      end
    end
  end
end
