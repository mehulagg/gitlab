import addExtraTokensForMergeRequests from '~/filtered_search/add_extra_tokens_for_merge_requests';
import { __ } from '~/locale';

const approvers = {
  condition: [
    {
      url: 'approver_usernames[]=None',
      tokenKey: 'approver',
      value: __('None'),
      operator: '=',
    },
    {
      url: 'not[approver_usernames][]=None',
      tokenKey: 'approver',
      value: __('None'),
      operator: '!=',
    },
    {
      url: 'approver_usernames[]=Any',
      tokenKey: 'approver',
      value: __('Any'),
      operator: '=',
    },
    {
      url: 'not[approver_usernames][]=Any',
      tokenKey: 'approver',
      value: __('Any'),
      operator: '!=',
    },
  ],
  token: {
    formattedKey: __('Approver'),
    key: 'approver',
    type: 'array',
    param: 'usernames[]',
    symbol: '@',
    icon: 'approval',
    tag: '@approver',
  },
};

export default IssuableTokenKeys => {
  addExtraTokensForMergeRequests(IssuableTokenKeys);
  const tokenPosition = 2;

  IssuableTokenKeys.tokenKeys.splice(tokenPosition, 0, ...[approvers.token]);
  IssuableTokenKeys.tokenKeysWithAlternative.splice(tokenPosition, 0, ...[approvers.token]);
  IssuableTokenKeys.conditions.push(...approvers.condition);
};
