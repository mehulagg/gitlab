# frozen_string_literal: true

RSpec.shared_examples 'common value stream service examples' do
  context 'when the user has no permission' do
    it 'returns error' do
      expect(subject).to be_error
      expect(subject.message).to eq('Forbidden')
    end
  end

  context 'when the license is missing' do
    before do
      group.add_developer(user)
      stub_licensed_features(cycle_analytics_for_groups: false)
    end

    it 'returns error' do
      expect(subject).to be_error
      expect(subject.message).to eq('Forbidden')
    end
  end
end
