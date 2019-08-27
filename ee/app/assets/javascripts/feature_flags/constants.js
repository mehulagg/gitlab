import _ from 'lodash-es';

export const ROLLOUT_STRATEGY_ALL_USERS = 'default';
export const ROLLOUT_STRATEGY_PERCENT_ROLLOUT = 'gradualRolloutUserId';
export const ROLLOUT_STRATEGY_USER_ID = 'userWithId';

export const PERCENT_ROLLOUT_GROUP_ID = 'default';

export const DEFAULT_PERCENT_ROLLOUT = '100';

export const ALL_ENVIRONMENTS_NAME = '*';

export const INTERNAL_ID_PREFIX = 'internal_';

export const fetchPercentageParams = _.property(['parameters', 'percentage']);
export const fetchUserIdParams = _.property(['parameters', 'userIds']);
