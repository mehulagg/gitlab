# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Insights::Reducers::BaseReducer do
  let(:issuable_relation) { Gitlab::Insights::Finders::IssuableFinder.new(project, nil, query: query).find }
  let(:project) { create(:project, :public) }
  let(:query) do
    {
      issuable_type: 'issue'
    }
  end

  it 'raises NotImplementedError' do
    expect { described_class.reduce(issuable_relation, period: query[:group_by]) }.to raise_error(NotImplementedError)
  end

  describe '#issuable_type' do
    context 'with issues' do
      it 'returns :issue' do
        expect(described_class.__send__(:new, issuable_relation).issuable_type).to eq(:issue)
      end
    end

    context 'with merge requests' do
      let(:query) do
        {
          issuable_type: 'merge_request'
        }
      end

      it 'returns :merge_request' do
        expect(described_class.__send__(:new, issuable_relation).issuable_type).to eq(:merge_request)
      end
    end
  end
end
