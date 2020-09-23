# frozen_string_literal: true

RSpec.shared_examples 'it should show Gmail Actions View Epic link' do
  it_behaves_like 'it should have Gmail Actions links'

  it { is_expected.to have_body_text('View Epic') }
end

RSpec.shared_examples 'an epic email starting a new thread with reply-by-email enabled' do
  include_examples 'a new thread email with reply-by-email enabled'

  context 'when reply-by-email is enabled with incoming address with %{key}' do
    it 'has a Reply-To header' do
      is_expected.to have_header 'Reply-To', /<reply+(.*)@#{Gitlab.config.gitlab.host}>\Z/
    end
  end

  context 'when reply-by-email is enabled with incoming address without %{key}' do
    include_context 'reply-by-email is enabled with incoming address without %{key}'
    include_examples 'a new thread email with reply-by-email enabled'

    it 'has a Reply-To header' do
      is_expected.to have_header 'Reply-To', /<reply@#{Gitlab.config.gitlab.host}>\Z/
    end
  end

  RSpec.shared_examples 'having group identification headers' do
    it 'has specific group headers' do
      is_expected.to have_header 'X-GitLab-Group-Id', /#{group.id}/
      is_expected.to have_header 'X-GitLab-Group-Path', /#{group.full_path}/
    end
  end
end
