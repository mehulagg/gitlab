import { OPERATOR_IS, OPERATOR_IS_NOT } from '~/issues_list/constants';

export const locationSearch = [
  '?search=find+issues',
  'author_username=homer',
  'not[author_username]=marge',
  'assignee_username[]=bart',
  'not[assignee_username][]=lisa',
  'milestone_title=season+4',
  'not[milestone_title]=season+20',
  'label_name[]=cartoon',
  'label_name[]=tv',
  'not[label_name][]=live action',
  'not[label_name][]=drama',
  'my_reaction_emoji=thumbsup',
  'confidential=no',
].join('&');

export const filteredTokens = [
  { type: 'author_username', value: { data: 'homer', operator: OPERATOR_IS } },
  { type: 'author_username', value: { data: 'marge', operator: OPERATOR_IS_NOT } },
  { type: 'assignee_username', value: { data: 'bart', operator: OPERATOR_IS } },
  { type: 'assignee_username', value: { data: 'lisa', operator: OPERATOR_IS_NOT } },
  { type: 'milestone', value: { data: 'season 4', operator: OPERATOR_IS } },
  { type: 'milestone', value: { data: 'season 20', operator: OPERATOR_IS_NOT } },
  { type: 'labels', value: { data: 'cartoon', operator: OPERATOR_IS } },
  { type: 'labels', value: { data: 'tv', operator: OPERATOR_IS } },
  { type: 'labels', value: { data: 'live action', operator: OPERATOR_IS_NOT } },
  { type: 'labels', value: { data: 'drama', operator: OPERATOR_IS_NOT } },
  { type: 'my_reaction_emoji', value: { data: 'thumbsup', operator: OPERATOR_IS } },
  { type: 'confidential', value: { data: 'no', operator: OPERATOR_IS } },
  { type: 'filtered-search-term', value: { data: 'find' } },
  { type: 'filtered-search-term', value: { data: 'issues' } },
];

export const apiParams = {
  author_username: 'homer',
  'not[author_username]': 'marge',
  assignee_username: 'bart',
  'not[assignee_username]': 'lisa',
  milestone: 'season 4',
  'not[milestone]': 'season 20',
  labels: 'cartoon,tv',
  'not[labels]': 'live action,drama',
  my_reaction_emoji: 'thumbsup',
  confidential: 'no',
};

export const urlParams = {
  author_username: ['homer'],
  'not[author_username]': ['marge'],
  'assignee_username[]': ['bart'],
  'not[assignee_username][]': ['lisa'],
  milestone_title: ['season 4'],
  'not[milestone_title]': ['season 20'],
  'label_name[]': ['cartoon', 'tv'],
  'not[label_name][]': ['live action', 'drama'],
  my_reaction_emoji: ['thumbsup'],
  confidential: ['no'],
};
