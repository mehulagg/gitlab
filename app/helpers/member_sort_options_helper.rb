# frozen_string_literal: true

module MemberSortOptionsHelper
  include SortingTitlesValuesHelper

  def member_sort_options_hash
    {
      sort_value_access_level_asc  => sort_title_access_level_asc,
      sort_value_access_level_desc => sort_title_access_level_desc,
      sort_value_last_joined       => sort_title_last_joined,
      sort_value_name              => sort_title_name_asc,
      sort_value_name_desc         => sort_title_name_desc,
      sort_value_oldest_joined     => sort_title_oldest_joined,
      sort_value_oldest_signin     => sort_title_oldest_signin,
      sort_value_recently_signin   => sort_title_recently_signin
    }
  end
end
