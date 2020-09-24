import { __ } from '~/locale';
import FilteredSearchTokenKeys from '~/filtered_search/filtered_search_token_keys';

const tokenKeys = [
  {
    formattedKey: __('Milestone'),
    key: 'milestone',
    type: 'string',
    param: 'title',
    symbol: '%',
    icon: 'clock',
    tag: '%milestone',
  },
  {
    formattedKey: __('Label'),
    key: 'label',
    type: 'array',
    param: 'name[]',
    symbol: '~',
    icon: 'labels',
    tag: '~label',
  },
];

const CodeReviewAnalyticsFilteredSearchTokenKeys = new FilteredSearchTokenKeys(tokenKeys);

export default CodeReviewAnalyticsFilteredSearchTokenKeys;
