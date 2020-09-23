export const createMRRule = () => ({
  id: 7,
  name: 'Amit',
  approvers: [{ id: 1 }, { id: 2 }],
  approvalsRequired: 2,
  minApprovalsRequired: 0,
  ruleType: 'regular',
});

export const createEmptyRule = () => ({
  id: 5,
  name: 'All Members',
  approvers: [],
  approvalsRequired: 3,
  minApprovalsRequired: 0,
  ruleType: 'any_approver',
});

export const createMRRuleWithSource = (rule = {}) => ({
  ...createEmptyRule(),
  ...createMRRule(),
  minApprovalsRequired: 1,
  hasSource: true,
  sourceId: 3,
  overridden: true,
  ...rule,
});
