# frozen_string_literal: true
module EpicsActions
  private

  def finder_type
    EpicsFinder
  end

  def collection_type
    @collection_type ||= 'Epic'
  end

  def default_sort_order
    default_sort_value || sort_value_recently_created
  end

  # Override this if you want your controller to have a different default sort order
  def default_sort_value
    nil
  end

  def update_cookie_value(value)
    case value
    when 'created_asc'     then sort_value_oldest_created
    when 'created_desc'    then sort_value_recently_created
    when 'start_date_asc'  then sort_value_start_date
    when 'end_date_asc'    then sort_value_end_date
    else
      super(value)
    end
  end
end
