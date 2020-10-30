# frozen_string_literal: true

RSpec.shared_context 'gitlab team member' do
  let_it_be(:namespace) { create(:group, name: 'GitLab.com', path: 'gitlab-com') }

  before do
    namespace.add_developer(user)
  end
end
