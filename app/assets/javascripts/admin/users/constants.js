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
