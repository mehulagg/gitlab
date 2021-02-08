# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'Debian Distribution Component' do |factory, container, can_freeze|
  let_it_be_with_refind(:component) { create(factory) } # rubocop:disable Rails/SaveBang
  let_it_be(:component_same_distribution, freeze: can_freeze) { create(factory, distribution: component.distribution) }
  let_it_be(:component_same_name, freeze: can_freeze) { create(factory, name: component.name) }

  subject { component }

  describe 'relationships' do
    it { is_expected.to belong_to(:distribution).class_name("Packages::Debian::#{container.capitalize}Distribution").inverse_of(:components) }
  end

  describe 'validations' do
    describe "#distribution" do
      it { is_expected.to validate_presence_of(:distribution) }
    end

    describe '#name' do
      it { is_expected.to validate_presence_of(:name) }

      it { is_expected.to allow_value('main').for(:name) }
      it { is_expected.to allow_value('non-free').for(:name) }
      it { is_expected.to allow_value('a' * 255).for(:name) }
      it { is_expected.not_to allow_value('a' * 256).for(:name) }
      it { is_expected.not_to allow_value('non/free').for(:name) }
      it { is_expected.not_to allow_value('hé').for(:name) }
    end
  end

  describe 'scopes' do
    describe '.with_distribution' do
      subject { described_class.with_distribution(component.distribution) }

      it 'does not return other distributions' do
        expect(subject.to_a).to eq([component, component_same_distribution])
      end
    end

    describe '.with_name' do
      subject { described_class.with_name(component.name) }

      it 'does not return other distributions' do
        expect(subject.to_a).to eq([component, component_same_name])
      end
    end
  end
end
