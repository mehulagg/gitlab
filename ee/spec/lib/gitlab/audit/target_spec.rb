# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Audit::Target do
  let(:object) { double('object') }

  subject { described_class.new(object) }

  describe '#id' do
    it 'returns object id' do
      allow(object).to receive(:id).and_return(object_id)

      expect(subject.id).to eq(object_id)
    end
  end

  describe '#type' do
    it 'returns object class name' do
      allow(object).to receive_message_chain(:class, :name).and_return('User')

      expect(subject.type).to eq('User')
    end
  end

  describe '#details' do
    using RSpec::Parameterized::TableSyntax

    where(:name, :title, :details) do
      'jackie' | 'wanderer' | 'jackie'
      'jackie' | nil        | 'jackie'
      nil      | 'wanderer' | 'wanderer'
      nil      | nil        | 'unknown'
    end

    before do
      allow(object).to receive(:name).and_return(name) if name
      allow(object).to receive(:title).and_return(title) if title
    end

    with_them do
      it 'returns details' do
        expect(subject.details).to eq(details)
      end
    end
  end
end
