<script>
import Draggable from 'vuedraggable';
import { mapState, mapGetters, mapActions } from 'vuex';
import { sortBy } from 'lodash';
import { GlAlert } from '@gitlab/ui';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import defaultSortableConfig from '~/sortable/sortable_config';
import { sortableEnd, sortableStart } from '~/boards/mixins/sortable_default_options';
import BoardColumn from './board_column.vue';
import BoardColumnDeprecated from './board_column_deprecated.vue';

export default {
  components: {
    BoardColumn: gon.features?.graphqlBoardLists ? BoardColumn : BoardColumnDeprecated,
    BoardAddNewColumn: () => import('./board_add_new_column.vue'),
    BoardContentSidebar: () => import('ee_component/boards/components/board_content_sidebar.vue'),
    EpicsSwimlanes: () => import('ee_component/boards/components/epics_swimlanes.vue'),
    GlAlert,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    lists: {
      type: Array,
      required: false,
      default: () => [],
    },
    canAdminList: {
      type: Boolean,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    ...mapState(['boardLists', 'error', 'addColumnFormVisible']),
    ...mapGetters(['isSwimlanesOn']),
    boardListsToUse() {
      return this.glFeatures.graphqlBoardLists || this.isSwimlanesOn
        ? sortBy([...Object.values(this.boardLists)], 'position')
        : this.lists;
    },
    canDragColumns() {
      return this.glFeatures.graphqlBoardLists && this.canAdminList;
    },
    boardColumnWrapper() {
      return this.canDragColumns ? Draggable : 'div';
    },
    draggableOptions() {
      const options = {
        ...defaultSortableConfig,
        disabled: this.disabled,
        draggable: '.is-draggable',
        fallbackOnBody: false,
        group: 'boards-list',
        tag: 'div',
        value: this.boardListsToUse,
      };

      return this.canDragColumns ? options : {};
    },
  },
  methods: {
    ...mapActions(['moveList']),
    afterFormEnters() {
      // todo: apparently no safari support for using scrollTo with options obj
      this.$refs.list.$el.scrollTo({ left: this.$refs.list.$el.scrollWidth, behavior: 'smooth' });
      // todo: set focus to form field
    },
    handleDragOnStart() {
      sortableStart();
    },

    handleDragOnEnd(params) {
      sortableEnd();

      const { item, newIndex, oldIndex, to } = params;

      const listId = item.dataset.id;
      const replacedListId = to.children[newIndex].dataset.id;

      this.moveList({
        listId,
        replacedListId,
        newIndex,
        adjustmentValue: newIndex < oldIndex ? 1 : -1,
      });
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="error" variant="danger" :dismissible="false">
      {{ error }}
    </gl-alert>
    <component
      :is="boardColumnWrapper"
      v-if="!isSwimlanesOn"
      ref="list"
      v-bind="draggableOptions"
      class="boards-list gl-w-full gl-py-5 gl-px-3 gl-white-space-nowrap"
      @start="handleDragOnStart"
      @end="handleDragOnEnd"
    >
      <transition-group name="slide">
        <board-column
          v-for="list in boardListsToUse"
          :key="list.id"
          ref="board"
          :can-admin-list="canAdminList"
          :list="list"
          :disabled="disabled"
        />
      </transition-group>

      <transition name="slide" @after-enter="afterFormEnters">
        <board-add-new-column v-if="addColumnFormVisible" />
      </transition>
    </component>

    <div v-else class="gl-display-flex">
      <epics-swimlanes
        ref="swimlanes"
        :lists="boardListsToUse"
        :can-admin-list="canAdminList"
        :disabled="disabled"
      />
    </div>

    <board-content-sidebar v-if="isSwimlanesOn || glFeatures.graphqlBoardLists" />
  </div>
</template>
