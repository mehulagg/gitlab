import { inactiveId } from '~/boards/constants';

export default () => ({
  endpoints: {},
  boardType: null,
  disabled: false,
  showPromotion: false,
  isShowingLabels: true,
  activeId: inactiveId,
  sidebarType: '',
  boardLists: {},
  listsFlags: {},
  issuesByListId: {},
  pageInfoByListId: {},
  issues: {},
  filterParams: {},
  error: undefined,
  message: {
    text: '',
    variant: 'error', // success | info | error, etc. Whatever gl-alert supports
  },
  // TODO: remove after ce/ee split of board_content.vue
  isShowingEpicsSwimlanes: false,
});
