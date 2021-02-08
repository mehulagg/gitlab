import { s__, __ } from '~/locale';
import Activate from './components/actions/activate.vue';
import Block from './components/actions/block.vue';
import Deactivate from './components/actions/deactivate.vue';
import DeleteWithContributions from './components/actions/delete_with_contributions.vue';
import Delete from './components/actions/delete.vue';
import Unblock from './components/actions/unblock.vue';
import Unlock from './components/actions/unlock.vue';

export const USER_AVATAR_SIZE = 32;

export const SHORT_DATE_FORMAT = 'd mmm, yyyy';

export const LENGTH_OF_USER_NOTE_TOOLTIP = 100;

export const ACTION_COMPONENTS = { Activate, Block, Deactivate, Unblock, Unlock };

export const DELETE_ACTION_COMPONENTS = { DeleteWithContributions, Delete };

export const I18N_USER_ACTIONS = {
  edit: __('Edit'),
  settings: __('Settings'),
  unlock: __('Unlock'),
  block: s__('AdminUsers|Block'),
  unblock: s__('AdminUsers|Unblock'),
  approve: s__('AdminUsers|Approve'),
  reject: s__('AdminUsers|Reject'),
  deactivate: s__('AdminUsers|Deactivate'),
  activate: s__('AdminUsers|Activate'),
  ldapBlocked: s__('AdminUsers|Cannot unblock LDAP blocked users'),
  delete: s__('AdminUsers|Delete user'),
  deleteWithContributions: s__('AdminUsers|Delete user and contributions'),
};
