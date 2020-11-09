<script>
import { mapGetters, mapActions, mapState } from 'vuex';
import BoardListHeader from 'ee_else_ce/boards/components/board_list_header.vue';
import EmptyComponent from '~/vue_shared/components/empty_component';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import BoardListNew from './board_list_new.vue';
import eventHub from '../eventhub';
import { ListType } from '../constants';

export default {
  components: {
    BoardPromotionState: EmptyComponent,
    BoardListHeader,
    BoardList: BoardListNew,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    list: {
      type: Object,
      default: () => ({}),
      required: false,
    },
    disabled: {
      type: Boolean,
      required: true,
    },
    canAdminList: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  inject: {
    boardId: {
      default: '',
    },
  },
  computed: {
    ...mapState(['filterParams']),
    ...mapGetters(['getIssues']),
    showBoardListAndBoardInfo() {
      return this.list.type !== ListType.promotion;
    },
    listIssues() {
      return this.getIssues(this.list.id);
    },
    shouldFetchIssues() {
      return this.list.type !== ListType.blank;
    },
  },
  watch: {
    filterParams: {
      handler() {
        if (this.shouldFetchIssues) {
          this.fetchIssuesForList({ listId: this.list.id });
        }
      },
      deep: true,
      immediate: true,
    },
  },
  mounted() {
    if (this.shouldFetchIssues) {
      this.fetchIssuesForList({ listId: this.list.id });
    }
  },
  methods: {
    ...mapActions(['fetchIssuesForList']),
    showListNewIssueForm(listId) {
      eventHub.$emit('showForm', listId);
    },
    // TODO: Reordering of lists https://gitlab.com/gitlab-org/gitlab/-/issues/280515
  },
};
</script>

<template>
  <div
    :class="{
      'is-draggable': !list.preset,
      'is-expandable': list.isExpandable,
      'is-collapsed': !list.isExpanded,
      'board-type-assignee': list.type === 'assignee',
    }"
    :data-id="list.id"
    class="board gl-display-inline-block gl-h-full gl-px-3 gl-vertical-align-top gl-white-space-normal"
    data-qa-selector="board_list"
  >
    <div
      class="board-inner gl-display-flex gl-flex-direction-column gl-relative gl-h-full gl-rounded-base"
    >
      <board-list-header :can-admin-list="canAdminList" :list="list" :disabled="disabled" />
      <board-list
        v-if="showBoardListAndBoardInfo"
        ref="board-list"
        :disabled="disabled"
        :issues="listIssues"
        :list="list"
      />

      <!-- Will be only available in EE -->
      <board-promotion-state v-if="list.id === 'promotion'" />
    </div>
  </div>
</template>
