# frozen_string_literal: true

class SidebarMenu # rubocop:disable Gitlab/NamespacedClass
  include ::Gitlab::Routing

  attr_reader :container

  def initialize(container)
    @container = container
    @items = []
  end

  def render?
    true
  end

  def has_items?
    @items.present?
  end

  def to_partial_path
    'projects/menus/sidebar_menu'
  end
end
