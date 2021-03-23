# frozen_string_literal: true

class Sidebar
  attr_reader :container, :menus, :context_menu

  def initialize(container)
    @context_menu = nil
    @menus = []
    @container = container
  end

  def add_menu(menu)
    @menus << menu
  end

  def set_context_menu(context_menu)
    @context_menu = context_menu
  end

  def to_partial_path
    'projects/sidebar'
  end
end
