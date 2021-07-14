# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExternalLinkHelper do
  include IconsHelper
  include ActionView::Helpers::TextHelper

  it 'returns external link with icon' do
    link = external_link('https://gitlab.com', 'https://gitlab.com').to_s
    expect(link).to start_with('<a target="_blank" rel="noopener noreferrer" href="https://gitlab.com">https://gitlab.com')
    expect(link).to include('data-testid="external-link-icon"')
  end

  it 'allows options when creating external link with icon' do
    link = external_link('https://gitlab.com', 'https://gitlab.com', { "data-foo": "bar", class: "externalLink" }).to_s

    expect(link).to start_with('<a target="_blank" rel="noopener noreferrer" data-foo="bar" class="externalLink" href="https://gitlab.com">https://gitlab.com')
    expect(link).to include('data-testid="external-link-icon"')
  end

  it 'sanitizes and returns external link with icon' do
    link = external_link('https://gitlab.com/users?return_to=javascript:alert()', 'https://gitlab.com/users?return_to=javascript:alert()').to_s
    expect('https://gitlab.com/users?return_to=javascript:alert()').to start_with('foo');
    #expect(link).to start_with('<a target="_blank" rel="noopener noreferrer" href="https://gitlab.com/users">https://gitlab.com/users')
    #expect(link).to include('data-testid="external-link-icon"')
  end
end
