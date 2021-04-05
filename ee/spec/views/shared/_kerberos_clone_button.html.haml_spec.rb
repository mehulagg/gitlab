# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'shared/kerberos_clone_button' do
  let(:partial) { 'shared/kerberos_clone_button' }

  let_it_be(:project) { create(:project) }
  let(:have_clone_button) { have_link('KRB5', href: project.kerberos_url_to_repo) }

  before do
    allow(view).to receive(:alternative_kerberos_url?).and_return(true)
  end

  subject { rendered }

  context 'Kerberos clone can be triggered' do
    it 'renders a working clone button' do
      render partial, container: project

      is_expected.to have_clone_button
    end
  end
end
