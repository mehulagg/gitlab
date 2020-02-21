# frozen_string_literal: true

module CapybaraNodeElementFix
  # Override `click` to prevent overlapping CSS selectors:
  #
  # See https://github.com/machinio/cuprite/blob/426e4f5/lib/capybara/cuprite/errors.rb#L41
  def click
    trigger('click')
  end
end

Capybara::Node::Element.prepend(CapybaraNodeElementFix)
