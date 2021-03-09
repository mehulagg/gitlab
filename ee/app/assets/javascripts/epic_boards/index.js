// This is a true violation of @gitlab/no-runtime-template-compiler, as it
// relies on app/views/shared/boards/_show.html.haml for its
// template.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { mapActions } from 'vuex';

import BoardSidebar from 'ee_component/boards/components/board_sidebar';
import toggleLabels from 'ee_component/boards/toggle_labels';

import BoardAddNewColumnTrigger from '~/boards/components/board_add_new_column_trigger.vue';
import BoardContent from '~/boards/components/board_content.vue';
import BoardAddIssuesModal from '~/boards/components/modal/index.vue';
import { issuableTypes } from '~/boards/constants';
import mountMultipleBoardsSwitcher from '~/boards/mount_multiple_boards_switcher';
import store from '~/boards/stores';
import createDefaultClient from '~/lib/graphql';

import '~/boards/filters/due_date_filters';
import { NavigationType, parseBoolean } from '~/lib/utils/common_utils';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const $boardApp = document.getElementById('board-app');

  // check for browser back and trigger a hard reload to circumvent browser caching.
  window.addEventListener('pageshow', (event) => {
    const isNavTypeBackForward =
      window.performance && window.performance.navigation.type === NavigationType.TYPE_BACK_FORWARD;

    if (event.persisted || isNavTypeBackForward) {
      window.location.reload();
    }
  });

  // eslint-disable-next-line no-new
  new Vue({
    el: $boardApp,
    components: {
      BoardContent,
      BoardSidebar,
      BoardAddIssuesModal,
      BoardSettingsSidebar: () => import('~/boards/components/board_settings_sidebar.vue'),
    },
    provide: {
      boardId: $boardApp.dataset.boardId,
      groupId: parseInt($boardApp.dataset.groupId, 10),
      rootPath: $boardApp.dataset.rootPath,
      currentUserId: gon.current_user_id || null,
      canUpdate: $boardApp.dataset.canUpdate,
      labelsFetchPath: $boardApp.dataset.labelsFetchPath,
      labelsManagePath: $boardApp.dataset.labelsManagePath,
      labelsFilterBasePath: $boardApp.dataset.labelsFilterBasePath,
      timeTrackingLimitToHours: parseBoolean($boardApp.dataset.timeTrackingLimitToHours),
      weightFeatureAvailable: parseBoolean($boardApp.dataset.weightFeatureAvailable),
      boardWeight: $boardApp.dataset.boardWeight
        ? parseInt($boardApp.dataset.boardWeight, 10)
        : null,
      scopedLabelsAvailable: parseBoolean($boardApp.dataset.scopedLabels),
    },
    store,
    apolloProvider,
    data() {
      return {
        state: {},
        loading: 0,
        boardsEndpoint: $boardApp.dataset.boardsEndpoint,
        recentBoardsEndpoint: $boardApp.dataset.recentBoardsEndpoint,
        listsEndpoint: $boardApp.dataset.listsEndpoint,
        disabled: parseBoolean($boardApp.dataset.disabled),
        bulkUpdatePath: $boardApp.dataset.bulkUpdatePath,
        parent: $boardApp.dataset.parent,
        detailIssueVisible: false,
      };
    },
    created() {
      this.setInitialBoardData({
        boardId: $boardApp.dataset.boardId,
        fullPath: $boardApp.dataset.fullPath,
        boardType: this.parent,
        disabled: this.disabled,
        issuableType: issuableTypes.epic,
        boardConfig: {
          milestoneId: parseInt($boardApp.dataset.boardMilestoneId, 10),
          milestoneTitle: $boardApp.dataset.boardMilestoneTitle || '',
          iterationId: parseInt($boardApp.dataset.boardIterationId, 10),
          iterationTitle: $boardApp.dataset.boardIterationTitle || '',
          assigneeId: $boardApp.dataset.boardAssigneeId,
          assigneeUsername: $boardApp.dataset.boardAssigneeUsername,
          labels: $boardApp.dataset.labels ? JSON.parse($boardApp.dataset.labels) : [],
          labelIds: $boardApp.dataset.labelIds ? JSON.parse($boardApp.dataset.labelIds) : [],
          weight: $boardApp.dataset.boardWeight
            ? parseInt($boardApp.dataset.boardWeight, 10)
            : null,
        },
      });
    },
    mounted() {
      this.performSearch();
    },
    methods: {
      ...mapActions(['setInitialBoardData', 'performSearch']),
      getNodes(data) {
        return data[this.parent]?.board?.lists.nodes;
      },
    },
  });

  const createColumnTriggerEl = document.querySelector('.js-create-column-trigger');
  if (createColumnTriggerEl) {
    // eslint-disable-next-line no-new
    new Vue({
      el: createColumnTriggerEl,
      components: {
        BoardAddNewColumnTrigger,
      },
      store,
      render(createElement) {
        return createElement(BoardAddNewColumnTrigger);
      },
    });
  }

  toggleLabels();

  mountMultipleBoardsSwitcher({
    fullPath: $boardApp.dataset.fullPath,
    rootPath: $boardApp.dataset.boardsEndpoint,
  });
};
