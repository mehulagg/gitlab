# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'shared/snippets/_snippet.html.haml' do
  let_it_be(:personal_snippet) { create(:personal_snippet) }

  before do
    allow(view).to receive(:current_application_settings).and_return(Gitlab::CurrentSettings.current_application_settings)
    allow(view).to receive(:can?) { true }

    @noteable_meta_data = Class.new { include Gitlab::NoteableMetadata }.new.noteable_meta_data([personal_snippet], 'Snippet')
  end

  it 'renders file count' do
    render 'shared/snippets/snippet', snippet: personal_snippet

    expect(rendered).to have_selector('span.file_count')
  end

  it 'does not render file count if snippet statistics are not available' do
    personal_snippet.statistics = nil

    render 'shared/snippets/snippet', snippet: personal_snippet

    expect(rendered).to_not have_selector('span.file_count')
  end
end
