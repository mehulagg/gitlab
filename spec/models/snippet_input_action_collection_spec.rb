# frozen_string_literal: true

require 'spec_helper'

describe SnippetInputActionCollection do
  let(:action_name)    { 'create' }
  let(:action)         { { action: action_name, file_path: 'foo', content: 'bar', previous_path: 'foobar' } }
  let(:data)           { [action, action] }

  it { is_expected.to delegate_method(:empty?).to(:actions) }

  describe '#to_commit_actions' do
    subject { described_class.new(data).to_commit_actions}

    it 'translates all actions to commit actions' do
      transformed_action = action.merge(action: action_name.to_sym)

      expect(subject).to eq [transformed_action, transformed_action]
    end
  end

  describe '#valid?' do
    subject { described_class.new(data).valid?}

    it 'returns true' do
      expect(subject).to be true
    end

    context 'when any of the actions is invalid' do
      let(:data) { [action, { action: 'foo' }, action]}

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
