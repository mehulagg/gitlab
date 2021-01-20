# frozen_string_literal: true

module LooksAhead
  extend ActiveSupport::Concern

  included do
    extras [:lookahead]
    attr_accessor :lookahead
  end

  def resolve(**args)
    self.lookahead = args.delete(:lookahead)

    resolve_with_lookahead(**args)
  end

  def apply_lookahead(query)
    selection = node_selection

    includes = preloads.each.flat_map do |name, requirements|
      selection&.selects?(name) ? requirements : []
    end
    all_preloads = (unconditional_includes + includes).uniq

    return query if all_preloads.empty?

    query.preload(*all_preloads) # rubocop: disable CodeReuse/ActiveRecord
  end

  private

  def unconditional_includes
    []
  end

  def preloads
    {}
  end

  def node_selection
    return unless lookahead

    if lookahead.selects?(:nodes)
      lookahead.selection(:nodes)
    elsif lookahead.selects?(:edges)
      lookahead.selection(:edges).selection(:node)
    end
  end

  def only_count_is_selected_with_merged_at_filter?(args)
    return unless lookahead
    
    argument_names = args.keys
    argument_names.delete(:sort)
    argument_names.delete(:merged_before)
    argument_names.delete(:merged_after)

    !lookahead.selects?(:nodes) && 
      !lookahead.selects?(:edges) && 
      lookahead.selects?(:count) && 
      lookahead.selections.size == 1 &&
      (args[:merged_after] || args[:merged_before]) &&
      argument_names.empty?
  end
end
