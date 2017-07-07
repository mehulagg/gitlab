require 'spec_helper'

describe Ci::GroupVariablePresenter do
  include Gitlab::Routing.url_helpers

  let(:group) { create(:group) }
  let(:variable) { create(:ci_group_variable, group: group) }

  subject(:presenter) do
    described_class.new(variable)
  end

  it 'inherits from Gitlab::View::Presenter::Delegated' do
    expect(described_class.superclass).to eq(Gitlab::View::Presenter::Delegated)
  end

  describe '#initialize' do
    it 'takes a variable and optional params' do
      expect { presenter }.not_to raise_error
    end

    it 'exposes variable' do
      expect(presenter.variable).to eq(variable)
    end

    it 'forwards missing methods to variable' do
      expect(presenter.key).to eq(variable.key)
    end
  end

  describe '#placeholder' do
    subject { described_class.new(variable).placeholder }

    it { is_expected.to eq('GROUP_VARIABLE') }
  end

  describe '#form_path' do
    context 'when variable is persisted' do
      subject { described_class.new(variable).form_path }

      it { is_expected.to eq(group_variable_path(group, variable)) }
    end

    context 'when variable is not persisted' do
      let(:variable) { build(:ci_group_variable, group: group) }
      subject { described_class.new(variable).form_path }

      it { is_expected.to eq(group_variables_path(group)) }
    end
  end

  describe '#edit_path' do
    subject { described_class.new(variable).edit_path }

    it { is_expected.to eq(group_variable_path(group, variable)) }
  end

  describe '#delete_path' do
    subject { described_class.new(variable).delete_path }

    it { is_expected.to eq(group_variable_path(group, variable)) }
  end
end
