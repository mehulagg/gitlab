# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::HiddenMenu do
  let_it_be(:project) { create(:project, :repository) }

  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project, current_ref: project.repository.root_ref) }

  describe '#render?' do
    subject { described_class.new(context) }

    context 'when menu does not have any menu items' do
      it 'returns false' do
        allow(subject).to receive(:has_items?).and_return(false)

        expect(subject.render?).to be false
      end
    end

    context 'when menu has menu items' do
      it 'returns true' do
        expect(subject.render?).to be true
      end
    end
  end

  describe 'Menu items' do
    subject { described_class.new(context).items.index { |e| e.item_id == item_id } }

    describe 'Activity' do
      let(:item_id) { :activity }

      specify { is_expected.not_to be_nil }

      describe 'when the user does not have access' do
        let(:user) { nil }

        specify { is_expected.not_to be_nil }
      end
    end

    describe 'Graph' do
      let(:item_id) { :graph }

      specify { is_expected.not_to be_nil }

      context 'when project repository is empty' do
        before do
          allow(project).to receive(:empty_repo?).and_return(true)
        end

        specify { is_expected.to be_nil }
      end

      describe 'when the user does not have access' do
        let(:user) { nil }

        specify { is_expected.to be_nil }
      end
    end

    describe 'New Issue' do
      let(:item_id) { :new_issue }

      specify { is_expected.not_to be_nil }

      describe 'when the user does not have access' do
        let(:user) { nil }

        specify { is_expected.to be_nil }
      end
    end

    describe 'Jobs' do
      let(:item_id) { :jobs }

      specify { is_expected.not_to be_nil }

      describe 'when the user does not have access' do
        let(:user) { nil }

        specify { is_expected.to be_nil }
      end
    end

    describe 'Commits' do
      let(:item_id) { :commits }

      specify { is_expected.not_to be_nil }

      context 'when project repository is empty' do
        before do
          allow(project).to receive(:empty_repo?).and_return(true)
        end

        specify { is_expected.to be_nil }
      end

      describe 'when the user does not have access' do
        let(:user) { nil }

        specify { is_expected.to be_nil }
      end
    end

    describe 'Issue Boards' do
      let(:item_id) { :issue_boards }

      specify { is_expected.not_to be_nil }

      describe 'when the user does not have access' do
        let(:user) { nil }

        specify { is_expected.to be_nil }
      end
    end
  end
end
