import { inactiveId } from '~/boards/constants';

export default () => ({
  endpoints: {},
  boardType: null,
  disabled: false,
  showPromotion: false,
  isShowingLabels: true,
  activeId: inactiveId,
  boardLists: [],
  issuesByListId: {},
  isLoadingIssues: false,
  filterParams: {},
  error: undefined,
  // TODO: remove after ce/ee split of board_content.vue
  isShowingEpicsSwimlanes: false,
});
