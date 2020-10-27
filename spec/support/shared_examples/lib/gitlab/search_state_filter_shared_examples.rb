# frozen_string_literal: true

RSpec.shared_examples 'search results filtered by state' do
  context 'state not provided' do
    let(:filters) { {} }

    it 'returns opened and closed results' do
      expect(results.objects(scope)).to include opened_result
      expect(results.objects(scope)).to include closed_result
    end
  end

  context 'all state' do
    let(:filters) { { state: 'all' } }

    it 'returns opened and closed results' do
      expect(results.objects(scope)).to include opened_result
      expect(results.objects(scope)).to include closed_result
    end
  end

  context 'closed state' do
    let(:filters) { { state: 'closed' } }

    it 'returns only closed results' do
      expect(results.objects(scope)).not_to include opened_result
      expect(results.objects(scope)).to include closed_result
    end
  end

  context 'opened state' do
    let(:filters) { { state: 'opened' } }

    it 'returns only opened results' do
      expect(results.objects(scope)).to include opened_result
      expect(results.objects(scope)).not_to include closed_result
    end
  end

  context 'unsupported state' do
    let(:filters) { { state: 'hello' } }

    it 'returns only opened results' do
      expect(results.objects(scope)).to include opened_result
      expect(results.objects(scope)).to include closed_result
    end
  end
end
