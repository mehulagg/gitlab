<script>
import { mapState, mapActions } from 'vuex';
import { escape } from 'lodash';

import { GlModal, GlSprintf } from '@gitlab/ui';

import { ChildType, RemoveItemModalProps, itemRemoveModalId } from '../constants';

export default {
  itemRemoveModalId,
  components: {
    GlModal,
    GlSprintf,
  },
  computed: {
    ...mapState(['parentItem', 'removeItemModalProps']),
    isEpic() {
      return this.removeItemType === ChildType.Epic;
    },
    removeItemType() {
      return this.removeItemModalProps.item.type;
    },
    modalTitle() {
      return this.removeItemType ? RemoveItemModalProps[this.removeItemType].title : '';
    },
    modalBody() {
      return RemoveItemModalProps[this.removeItemType].body;
    },
    targetTitle() {
      return escape(this.removeItemModalProps.item.title);
    },
    parentTitle() {
      return escape(this.parentItem.title);
    },
  },
  methods: {
    ...mapActions(['removeItem']),
  },
};
</script>

<template>
  <gl-modal
    :modal-id="$options.itemRemoveModalId"
    :title="modalTitle"
    :ok-title="__('Remove')"
    ok-variant="danger"
    no-fade
    @ok="
      removeItem({
        parentItem: removeItemModalProps.parentItem,
        item: removeItemModalProps.item,
      })
    "
  >
    <p v-if="removeItemType">
      <gl-sprintf :message="modalBody">
        <template #b="{ content }">
          <b>{{ content }}</b>
        </template>
        <template v-if="isEpic" #targetEpicTitle>
          {{ targetTitle }}
        </template>
        <template v-else #targetIssueTitle>
          {{ targetTitle }}
        </template>
        <template #parentEpicTitle>
          {{ parentTitle }}
        </template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
