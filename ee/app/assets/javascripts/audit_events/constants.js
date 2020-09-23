import { __, s__ } from '~/locale';

import UserToken from './components/tokens/user_token.vue';
import MemberToken from './components/tokens/member_token.vue';
import ProjectToken from './components/tokens/project_token.vue';
import GroupToken from './components/tokens/group_token.vue';

const DEFAULT_TOKEN_OPTIONS = {
  operators: [{ value: '=', description: __('is'), default: 'true' }],
  unique: true,
};

// Due to the i18n eslint rule we can't have a capitalized string even if it is a case-aware URL param
/* eslint-disable @gitlab/require-i18n-strings */
const ENTITY_TYPES = {
  USER: 'User',
  AUTHOR: 'Author',
  GROUP: 'Group',
  PROJECT: 'Project',
};
/* eslint-enable @gitlab/require-i18n-strings */

export const AUDIT_FILTER_CONFIGS = [
  {
    ...DEFAULT_TOKEN_OPTIONS,
    icon: 'user',
    title: s__('AuditLogs|User Events'),
    type: 'user',
    entityType: ENTITY_TYPES.USER,
    token: UserToken,
  },
  {
    ...DEFAULT_TOKEN_OPTIONS,
    icon: 'user',
    title: s__('AuditLogs|Member Events'),
    type: 'member',
    entityType: ENTITY_TYPES.AUTHOR,
    token: MemberToken,
  },
  {
    ...DEFAULT_TOKEN_OPTIONS,
    icon: 'bookmark',
    title: s__('AuditLogs|Project Events'),
    type: 'project',
    entityType: ENTITY_TYPES.PROJECT,
    token: ProjectToken,
  },
  {
    ...DEFAULT_TOKEN_OPTIONS,
    icon: 'group',
    title: s__('AuditLogs|Group Events'),
    type: 'group',
    entityType: ENTITY_TYPES.GROUP,
    token: GroupToken,
  },
];

export const AVAILABLE_TOKEN_TYPES = AUDIT_FILTER_CONFIGS.map(token => token.type);
