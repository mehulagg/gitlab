# frozen_string_literal: true

RSpec.shared_examples_for 'issuable bulk dropdown' do |path|
  let(:parent) { create(:group) }
  let(:feature_enabled) { true }

  # We use `view.render`, because just `render` throws a "no implicit conversion of nil into String" exception
  # https://gitlab.com/gitlab-org/gitlab/-/merge_requests/53093#note_499060593
  subject { view.render(path, { parent: parent }) }

  before do
    stub_licensed_features(feature_id => feature_enabled)
  end

  it 'renders hidden input' do
    expect(subject).to have_css(input_selector, visible: false)
  end

  it 'renders vue root' do
    expect(subject).to have_css(root_selector)
  end

  context 'without parent' do
    let(:parent) { nil }

    it 'is nil' do
      expect(subject).to be_nil
    end
  end

  context 'without feature' do
    let(:feature_enabled) { false }

    it 'is nil' do
      expect(subject).to be_nil
    end
  end
end
