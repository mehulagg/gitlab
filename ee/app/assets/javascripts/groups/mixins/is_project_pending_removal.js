import { ITEM_TYPE } from '~/groups/constants';

export default {
  computed: {
    isProjectPendingRemoval() {
      return this.item.type === ITEM_TYPE.PROJECT && this.item.pendingRemoval;
    },
  },
};
