# frozen_string_literal: true

RSpec.shared_examples 'a visible dismissible qrtly reconciliation alert' do
  shared_examples 'a visible alert' do
    it 'displays an alert' do
      expect(page).to have_selector('[data-testid="qrtly-reconciliation-alert"]')
    end
  end

  context 'when dismissed' do
    before do
      within '[data-testid="qrtly-reconciliation-alert"]' do
        click_button 'Dismiss'
      end
    end

    it_behaves_like 'a hidden qrtly reconciliation alert'

    context 'when visiting again' do
      before do
        visit current_path
      end

      it_behaves_like 'a hidden qrtly reconciliation alert'
    end
  end
end

RSpec.shared_examples 'a hidden qrtly reconciliation alert' do
  it 'does not display an alert' do
    expect(page).not_to have_selector('[data-testid="qrtly-reconciliation-alert"]')
  end
end
