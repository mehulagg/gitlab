import { inactiveId } from '~/boards/constants';

export default () => ({
  endpoints: {},
  boardType: null,
  disabled: false,
  showPromotion: false,
  isShowingLabels: true,
  activeId: inactiveId,
  sidebarType: '',
  boardLists: [],
  issuesByListId: {},
  pageInfoByListId: {},
  issues: {},
  filterParams: {},
  error: undefined,
  // TODO: remove after ce/ee split of board_content.vue
  isShowingEpicsSwimlanes: false,
});
