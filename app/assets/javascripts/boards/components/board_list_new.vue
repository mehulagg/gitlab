<script>
import { mapActions, mapState } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import boardNewIssue from './board_new_issue.vue';
import boardCard from './board_card.vue';
import eventHub from '../eventhub';
import boardsStore from '../stores/boards_store';
import { sprintf, __ } from '~/locale';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  name: 'BoardList',
  components: {
    boardCard,
    boardNewIssue,
    GlLoadingIcon,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    disabled: {
      type: Boolean,
      required: true,
    },
    list: {
      type: Object,
      required: true,
    },
    issues: {
      type: Array,
      required: true,
    },
    loading: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      scrollOffset: 250,
      filters: boardsStore.state.filters,
      showCount: false,
      showIssueForm: false,
    };
  },
  computed: {
    ...mapState(['pageInfoByListId']),
    paginatedIssueText() {
      return sprintf(__('Showing %{pageSize} of %{total} issues'), {
        pageSize: this.issues.length,
        total: this.list.issuesSize,
      });
    },
    issuesSizeExceedsMax() {
      return this.list.maxIssueCount > 0 && this.list.issuesSize > this.list.maxIssueCount;
    },
    hasNextPage() {
      return this.pageInfoByListId[this.list.id].hasNextPage;
    },
  },
  watch: {
    filters: {
      handler() {
        this.list.loadingMore = false;
        this.$refs.list.scrollTop = 0;
      },
      deep: true,
    },
    issues() {
      this.$nextTick(() => {
        if (this.scrollHeight() > Math.ceil(this.listHeight())) {
          this.showCount = true;
        } else {
          this.showCount = false;
        }
      });
    },
  },
  created() {
    eventHub.$on(`toggle-issue-form-${this.list.id}`, this.toggleForm);
    eventHub.$on(`scroll-board-list-${this.list.id}`, this.scrollToTop);
  },
  mounted() {
    // Scroll event on list to load more
    this.$refs.list.addEventListener('scroll', this.onScroll);
  },
  beforeDestroy() {
    eventHub.$off(`toggle-issue-form-${this.list.id}`, this.toggleForm);
    eventHub.$off(`scroll-board-list-${this.list.id}`, this.scrollToTop);
    this.$refs.list.removeEventListener('scroll', this.onScroll);
  },
  methods: {
    ...mapActions(['fetchIssuesForList']),
    listHeight() {
      return this.$refs.list.getBoundingClientRect().height;
    },
    scrollHeight() {
      return this.$refs.list.scrollHeight;
    },
    scrollTop() {
      return this.$refs.list.scrollTop + this.listHeight();
    },
    scrollToTop() {
      this.$refs.list.scrollTop = 0;
    },
    loadNextPage() {
      const loadingDone = () => {
        this.list.loadingMore = false;
      };
      this.list.loadingMore = true;
      this.fetchIssuesForList({ listId: this.list.id, fetchNext: true })
        .then(loadingDone)
        .catch(loadingDone);
    },
    toggleForm() {
      this.showIssueForm = !this.showIssueForm;
    },
    onScroll() {
      if (
        !this.list.loadingMore &&
        this.scrollTop() > this.scrollHeight() - this.scrollOffset &&
        this.hasNextPage
      ) {
        this.loadNextPage();
      }
    },
  },
};
</script>

<template>
  <div
    :class="{
      'gl-display-none': !list.isExpanded,
      'gl-display-flex gl-flex-direction-column': list.isExpanded,
    }"
    class="board-list-component gl-relative gl-h-full"
    data-qa-selector="board_list_cards_area"
  >
    <div
      v-if="loading"
      class="board-list-loading gl-text-center"
      :aria-label="__('Loading issues')"
    >
      <gl-loading-icon />
    </div>
    <board-new-issue v-if="list.type !== 'closed' && showIssueForm" :list="list" />
    <ul
      v-show="!loading"
      ref="list"
      :data-board="list.id"
      :data-board-type="list.type"
      :class="{ 'is-smaller': showIssueForm, 'bg-danger-100': issuesSizeExceedsMax }"
      class="board-list gl-w-full gl-h-full list-unstyled gl-mb-0 gl-p-2 js-board-list"
    >
      <board-card
        v-for="(issue, index) in issues"
        ref="issue"
        :key="issue.id"
        :index="index"
        :list="list"
        :issue="issue"
        :disabled="disabled"
      />
      <li v-if="showCount" class="board-list-count gl-text-center" data-issue-id="-1">
        <gl-loading-icon v-show="list.loadingMore" label="Loading more issues" />
        <span v-if="list.issues.length === list.issuesSize">{{ __('Showing all issues') }}</span>
        <span v-else>{{ paginatedIssueText }}</span>
      </li>
    </ul>
  </div>
</template>
