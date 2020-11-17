<script>
import { mapState, mapActions } from 'vuex';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';

import TreeDragAndDropMixin from '../mixins/tree_dd_mixin';

import { ChildType } from '../constants';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
  },
  mixins: [TreeDragAndDropMixin],
  props: {
    parentItem: {
      type: Object,
      required: true,
    },
    children: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      fetchInProgress: false,
    };
  },
  computed: {
    ...mapState(['childrenFlags', 'userSignedIn']),
    hasMoreChildren() {
      const flags = this.childrenFlags[this.parentItem.reference];

      return flags.hasMoreEpics || flags.hasMoreIssues;
    },
  },
  methods: {
    ...mapActions(['fetchNextPageItems', 'reorderItem', 'moveItem', 'toggleItem']),
    handleShowMoreClick() {
      this.fetchInProgress = true;
      this.fetchNextPageItems({
        parentItem: this.parentItem,
      })
        .then(() => {
          this.fetchInProgress = false;
        })
        .catch(() => {
          this.fetchInProgress = false;
        });
    },
    onMove(e) {
      const item = e.relatedContext.element;
      if (item?.type === ChildType.Epic)
        this.toggleItem({
          parentItem: item,
          isDragging: true,
        });
    },
  },
};
</script>

<template>
  <component
    :is="treeRootWrapper"
    v-bind="treeRootOptions"
    class="list-unstyled related-items-list tree-root"
    :move="onMove"
    @start="handleDragOnStart"
    @end="handleDragOnEnd"
  >
    <tree-item v-for="item in children" :key="item.id" :parent-item="parentItem" :item="item" />
    <li v-if="hasMoreChildren" class="tree-item list-item pt-0 pb-0 d-flex justify-content-center">
      <gl-button
        v-if="!fetchInProgress"
        class="d-inline-block mb-2"
        variant="link"
        @click="handleShowMoreClick($event)"
        >{{ s__('Epics|Show more') }}</gl-button
      >
      <gl-loading-icon v-else size="sm" class="mt-1 mb-1" />
    </li>
  </component>
</template>
