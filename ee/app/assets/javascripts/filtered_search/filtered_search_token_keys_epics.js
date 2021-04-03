import FilteredSearchTokenKeys from '~/filtered_search/filtered_search_token_keys';
import { __ } from '~/locale';

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

if (gon.current_user_id) {
  // Appending tokenkeys only logged-in
  tokenKeys.push({
    formattedKey: __('My-Reaction'),
    key: 'my-reaction',
    type: 'string',
    param: 'emoji',
    symbol: '',
    icon: 'thumb-up',
    tag: 'emoji',
  });
}

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
  {
    url: 'my_reaction_emoji=None',
    tokenKey: 'my-reaction',
    value: __('None'),
  },
  {
    url: 'my_reaction_emoji=Any',
    tokenKey: 'my-reaction',
    value: __('Any'),
  },
];

const EpicsFilteredSearchTokenKeysEE = new FilteredSearchTokenKeys(
  [...tokenKeys],
  alternativeTokenKeys,
  [...conditions],
);

export default EpicsFilteredSearchTokenKeysEE;
