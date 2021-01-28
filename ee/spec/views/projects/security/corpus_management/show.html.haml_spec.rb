# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "projects/security/corpus_management/show", type: :view do
  before do
    @project = create(:project)
    render
  end

  it 'renders Vue app root' do
    expect(rendered).to have_selector('.js-corpus-management')
  end

  it 'passes project\'s full path' do
    expect(rendered).to include @project.full_path
  end
end
