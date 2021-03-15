# frozen_string_literal: true

RSpec.shared_examples 'cannot search settings' do
  it 'does note have search settings field' do
    expect(page).not_to have_field(placeholder: SearchHelpers::INPUT_PLACEHOLDER)
  end
end

RSpec.shared_examples 'can search settings' do |search_term, non_match_section|
  it 'has search settings field' do
    expect(page).to have_field(placeholder: SearchHelpers::INPUT_PLACEHOLDER)
  end

  it 'hides unmatching sections on search' do
    expect(page).to have_content(non_match_section)

    fill_in SearchHelpers::INPUT_PLACEHOLDER, with: search_term

    expect(page).to have_content(search_term)
    expect(page).not_to have_content(non_match_section)
  end
end
