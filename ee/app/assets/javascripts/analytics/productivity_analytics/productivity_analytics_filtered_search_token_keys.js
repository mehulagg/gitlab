import { __ } from '~/locale';
import FilteredSearchTokenKeys from '~/filtered_search/filtered_search_token_keys';

const tokenKeys = [
  {
    formattedKey: __('Author'),
    key: 'author',
    type: 'string',
    param: 'username',
    symbol: '@',
    icon: 'pencil',
    tag: '@author',
  },
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

const ProductivityAnalyticsFilteredSearchTokenKeys = new FilteredSearchTokenKeys(tokenKeys);

export default ProductivityAnalyticsFilteredSearchTokenKeys;
