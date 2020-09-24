# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::StatusPage::Filter::MentionAnonymizationFilter do
  include FilterSpecHelper

  it 'replaces user link with anonymized text' do
    original_html = "Hi #{user_link('alice')}, #{user_link('bob')} is calling."
    context = {}

    doc = filter(original_html, context)

    expect(doc.to_s)
      .to eq('Hi Incident Responder, Incident Responder is calling.')
  end

  private

  def user_link(username)
    name = username.capitalize

    %{<a href="/#{username}" data-user="1" data-reference-type="user" data-container="body" data-placement="top" data-html="true" class="gfm gfm-project_member js-user-link" title="#{name}">@#{username}</a>}
  end
end
