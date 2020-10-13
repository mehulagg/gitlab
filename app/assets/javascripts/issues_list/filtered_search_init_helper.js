import { urlParamsToObject } from '~/lib/utils/common_utils';

import { __ } from '~/locale';
import { AvailableSortOptionsForJira } from './constants';

export function initialFilterValue() {
  const value = [];
  const { search } = urlParamsToObject(window.location.search);

  if (search) {
    value.push(search);
  }
  return value;
}

export function initialSortBy() {
  const { sort } = urlParamsToObject(window.location.search);
  return sort || 'created_desc';
}

export function getJiraFilteredSearchOptions(
  projectPath,
  availableSortOptions = AvailableSortOptionsForJira,
) {
  return {
    projectPath,
    availableSortOptions,
    searchInputPlaceholder: __('Search Jira issues'),
    initialFilterValue: initialFilterValue(),
    initialSortBy: initialSortBy(),
  };
}
