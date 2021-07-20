# frozen_string_literal: true
module EE
  module SortingHelper
    extend ::Gitlab::Utils::Override

    override :sort_options_hash
    def sort_options_hash
      {
        sort_value_start_date => sort_title_start_date,
        sort_value_end_date   => sort_title_end_date,
        sort_value_less_weight => sort_title_less_weight,
        sort_value_more_weight => sort_title_more_weight,
        sort_value_weight      => sort_title_weight,
        sort_value_blocking_desc => sort_title_blocking
      }.merge(super)
    end

    def epics_sort_options_hash
      {
        sort_value_created_date => sort_title_created_date,
        sort_value_oldest_created => sort_title_created_date,
        sort_value_recently_created => sort_title_created_date,
        sort_value_oldest_updated => sort_title_recently_updated,
        sort_value_recently_updated => sort_title_recently_updated,
        sort_value_start_date_later => sort_title_start_date,
        sort_value_start_date_soon => sort_title_start_date,
        sort_value_end_date_later => sort_title_end_date,
        sort_value_end_date => sort_title_end_date,
        sort_value_title => sort_title_title,
        sort_value_title_desc => sort_title_title
      }
    end

    # This method is used to find the opposite ordering parameter for the sort button in the UI.
    # Hash key is the descending sorting order and the sort value is the opposite of it for the same field.
    # For example: created_at_asc => created_at_desc
    def epics_ordering_options_hash
      {
        sort_value_oldest_created => sort_value_recently_created,
        sort_value_oldest_updated => sort_value_recently_updated,
        sort_value_start_date_soon => sort_value_start_date_later,
        sort_value_end_date => sort_value_end_date_later,
        sort_value_title => sort_value_title_desc
      }
    end

    override :issuable_reverse_sort_order_hash
    def issuable_reverse_sort_order_hash
      {
        sort_value_weight => sort_value_more_weight
      }.merge(super)
    end

    override :issuable_sort_option_overrides
    def issuable_sort_option_overrides
      {
        sort_value_more_weight => sort_value_weight
      }.merge(super)
    end

    override :sort_direction_icon
    def sort_direction_icon(sort_value)
      if sort_value == sort_value_weight
        'sort-lowest'
      else
        super
      end
    end

    # Creates a button with the opposite ordering for the current field in UI.
    def sort_order_button(sort)
      opposite_sorting_param = epics_ordering_options_hash[sort] || epics_ordering_options_hash.key(sort)
      sort_icon = sort.end_with?('desc') ? 'sort-highest' : 'sort-lowest'

      link_to sprite_icon(sort_icon),
              page_filter_path(sort: opposite_sorting_param),
              class: "btn gl-button btn-default btn-icon has-tooltip qa-reverse-sort btn-sort-direction",
              title: _("Sort direction")
    end
  end
end
