import Vue from 'vue';
import VueApollo from 'vue-apollo';
import BoardsSelector from 'ee_else_ce/boards/components/boards_selector.vue';
import BoardsSelectorDeprecated from '~/boards/components/boards_selector_deprecated.vue';
import store from '~/boards/stores';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default (params = {}) => {
  const boardsSwitcherElement = document.getElementById('js-multiple-boards-switcher');
  return new Vue({
    el: boardsSwitcherElement,
    components: {
      BoardsSelector,
      BoardsSelectorDeprecated,
    },
    apolloProvider,
    store,
    provide: {
      fullPath: params.fullPath,
      rootPath: params.rootPath,
      isEpicBoard: params.isEpicBoard,
    },
    data() {
      const { dataset } = boardsSwitcherElement;

      const boardsSelectorProps = {
        ...dataset,
        currentBoard: JSON.parse(dataset.currentBoard),
        hasMissingBoards: parseBoolean(dataset.hasMissingBoards),
        canAdminBoard: parseBoolean(dataset.canAdminBoard),
        multipleIssueBoardsAvailable: parseBoolean(dataset.multipleIssueBoardsAvailable),
        projectId: dataset.projectId ? Number(dataset.projectId) : 0,
        groupId: Number(dataset.groupId),
        scopedIssueBoardFeatureEnabled: parseBoolean(dataset.scopedIssueBoardFeatureEnabled),
        weights: JSON.parse(dataset.weights),
      };

      return { boardsSelectorProps };
    },
    render(createElement) {
      if (params.isEpicBoard) {
        return createElement(BoardsSelector, {
          props: this.boardsSelectorProps,
        });
      }
      return createElement(BoardsSelectorDeprecated, {
        props: this.boardsSelectorProps,
      });
    },
  });
};
