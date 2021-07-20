# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'shared/kerberos_clone_button' do
  let_it_be(:project) { create(:project) }

  let(:partial) { 'shared/kerberos_clone_button' }

  before do
    allow(view).to receive(:alternative_kerberos_url?).and_return(true)
  end

  subject { rendered }

  context 'Kerberos clone can be triggered' do
    it 'renders a working clone button for the project' do
      render partial, container: project

      is_expected.to have_link('KRB5', href: project.kerberos_url_to_repo)
    end

    it 'renders a working clone button for the wiki' do
      render partial, container: project.wiki

      is_expected.to have_link('KRB5', href: project.wiki.kerberos_url_to_repo)
    end
  end
end
