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
    formattedKey: __('Label'),
    key: 'label',
    type: 'array',
    param: 'name[]',
    symbol: '~',
    icon: 'labels',
    tag: '~label',
  },
];

const alternativeTokenKeys = [
  {
    formattedKey: __('Label'),
    key: 'label',
    type: 'string',
    param: 'name',
    symbol: '~',
  },
];

const conditions = [
  {
    url: 'label_name[]=No+Label',
    tokenKey: 'label',
    value: 'none',
    operator: '=',
  },
  {
    url: 'not[label_name][]=No+Label',
    tokenKey: 'label',
    value: 'none',
    operator: '!=',
  },
];

const EpicsFilteredSearchTokenKeysEE = new FilteredSearchTokenKeys(
  [...tokenKeys],
  alternativeTokenKeys,
  [...conditions],
);

export default EpicsFilteredSearchTokenKeysEE;
