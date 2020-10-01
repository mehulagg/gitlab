# frozen_string_literal: true

RSpec.shared_examples 'size checker for snippet without project' do |action|
  context 'when snippet does not belong to a project' do
    subject { build(:personal_snippet) }

    it 'sets up size checker', :aggregate_failures do
      expect(checker.current_size).to eq(current_size.megabytes)
      expect(checker.limit).to eq(Gitlab::CurrentSettings.snippet_size_limit)
      expect(checker.total_repository_size_excess).to eq(0)
      expect(checker.additional_purchased_storage).to eq(0)
      expect(checker.enabled?).to be_truthy
    end
  end
end
