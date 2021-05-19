# frozen_string_literal: true

RSpec.shared_context 'integration activation' do
  def click_active_checkbox
    find('label', text: 'Active').click
  end

  def click_save_integration
    click_button('Save changes')
  end

  def click_save_settings_modal
    click_button('Save')
  end
end
