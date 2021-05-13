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
  'iteration_title=season:+%234',
  'not[iteration_title]=season:+%2320',
  'epic_id=12',
  'not[epic_id]=34',
  'weight=1',
  'not[weight]=3',
].join('&');

export const locationSearchWithSpecialValues = [
  'assignee_id=None',
  'my_reaction_emoji=None',
  'iteration_id=Current',
  'epic_id=None',
  'weight=None',
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
  { type: 'iteration', value: { data: 'season: #4', operator: OPERATOR_IS } },
  { type: 'iteration', value: { data: 'season: #20', operator: OPERATOR_IS_NOT } },
  { type: 'epic_id', value: { data: '12', operator: OPERATOR_IS } },
  { type: 'epic_id', value: { data: '34', operator: OPERATOR_IS_NOT } },
  { type: 'weight', value: { data: '1', operator: OPERATOR_IS } },
  { type: 'weight', value: { data: '3', operator: OPERATOR_IS_NOT } },
  { type: 'filtered-search-term', value: { data: 'find' } },
  { type: 'filtered-search-term', value: { data: 'issues' } },
];

export const filteredTokensWithSpecialValues = [
  { type: 'assignee_username', value: { data: 'None', operator: OPERATOR_IS } },
  { type: 'my_reaction_emoji', value: { data: 'None', operator: OPERATOR_IS } },
  { type: 'iteration', value: { data: 'Current', operator: OPERATOR_IS } },
  { type: 'epic_id', value: { data: 'None', operator: OPERATOR_IS } },
  { type: 'weight', value: { data: 'None', operator: OPERATOR_IS } },
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
  iteration_title: 'season: #4',
  'not[iteration_title]': 'season: #20',
  epic_id: '12',
  'not[epic_id]': '34',
  weight: '1',
  'not[weight]': '3',
};

export const apiParamsWithSpecialValues = {
  assignee_id: 'None',
  my_reaction_emoji: 'None',
  iteration_id: 'Current',
  epic_id: 'None',
  weight: 'None',
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
  iteration_title: ['season: #4'],
  'not[iteration_title]': ['season: #20'],
  epic_id: ['12'],
  'not[epic_id]': ['34'],
  weight: ['1'],
  'not[weight]': ['3'],
};

export const urlParamsWithSpecialValues = {
  assignee_id: ['None'],
  my_reaction_emoji: ['None'],
  iteration_id: ['Current'],
  epic_id: ['None'],
  weight: ['None'],
};
