# frozen_string_literal: true

module MemberSortOptionsHelper
  def member_sort_options_hash
    {
      SortingTitlesValues.sort_value_access_level_asc  => SortingTitlesValues.sort_title_access_level_asc,
      SortingTitlesValues.sort_value_access_level_desc => SortingTitlesValues.sort_title_access_level_desc,
      SortingTitlesValues.sort_value_last_joined       => SortingTitlesValues.sort_title_last_joined,
      SortingTitlesValues.sort_value_name              => SortingTitlesValues.sort_title_name_asc,
      SortingTitlesValues.sort_value_name_desc         => SortingTitlesValues.sort_title_name_desc,
      SortingTitlesValues.sort_value_oldest_joined     => SortingTitlesValues.sort_title_oldest_joined,
      SortingTitlesValues.sort_value_oldest_signin     => SortingTitlesValues.sort_title_oldest_signin,
      SortingTitlesValues.sort_value_recently_signin   => SortingTitlesValues.sort_title_recently_signin
    }
  end
end
