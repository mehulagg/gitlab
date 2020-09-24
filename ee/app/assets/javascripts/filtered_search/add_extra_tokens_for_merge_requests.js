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

const approvedBy = {
  condition: [
    {
      url: 'approved_by_usernames[]=None',
      tokenKey: 'approved-by',
      value: __('None'),
      operator: '=',
    },
    {
      url: 'not[approved_by_usernames][]=None',
      tokenKey: 'approved-by',
      value: __('None'),
      operator: '!=',
    },
    {
      url: 'approved_by_usernames[]=Any',
      tokenKey: 'approved-by',
      value: __('Any'),
      operator: '=',
    },
    {
      url: 'not[approved_by_usernames][]=Any',
      tokenKey: 'approved-by',
      value: __('Any'),
      operator: '!=',
    },
  ],
  token: {
    formattedKey: __('Approved-By'),
    key: 'approved-by',
    type: 'array',
    param: 'usernames[]',
    symbol: '@',
    icon: 'approval',
    tag: '@approved-by',
  },
};

export default IssuableTokenKeys => {
  addExtraTokensForMergeRequests(IssuableTokenKeys);
  const tokenPosition = 2;
  const combinedTokens = [approvers.token, approvedBy.token];
  const combinedConditions = [approvers.condition, approvedBy.condition];

  IssuableTokenKeys.tokenKeys.splice(tokenPosition, 0, ...combinedTokens);
  IssuableTokenKeys.tokenKeysWithAlternative.splice(tokenPosition, 0, ...combinedTokens);
  IssuableTokenKeys.conditions.push(...combinedConditions);
};
