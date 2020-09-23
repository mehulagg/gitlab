# frozen_string_literal: true

RSpec.shared_examples_for 'EE wiki model' do
  let_it_be(:user) { create(:user) }
  let(:wiki) { described_class.for_container(wiki_container, user) }

  subject { wiki }

  describe '#kerberos_url_to_repo' do
    it 'returns valid kerberos url for this repo' do
      gitlab_kerberos_url = Gitlab.config.build_gitlab_kerberos_url
      repo_kerberos_url = "#{gitlab_kerberos_url}/#{subject.full_path}.git"

      expect(subject.kerberos_url_to_repo).to eq(repo_kerberos_url)
    end
  end
end
