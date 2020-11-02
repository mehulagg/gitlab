import { shallowMount } from '@vue/test-utils';
import BoardContentSidebar from 'ee/boards/components/board_content_sidebar.vue';
import BoardContent from '~/boards/components/board_content.vue';
import { createStore } from '~/boards/stores';

describe('ee/BoardContent', () => {
  let wrapper;
  let store;
  window.gon = { features: {} };

  const createComponent = () => {
    wrapper = shallowMount(BoardContent, {
      store,
      provide: {
        timeTrackingLimitToHours: false,
      },
      propsData: {
        lists: [],
        canAdminList: false,
        disabled: false,
      },
      stubs: {
        'board-content-sidebar': BoardContentSidebar,
      },
    });
  };

  beforeEach(() => {
    store = createStore();
  });

  afterEach(() => {
    window.gon.features = {};
    wrapper.destroy();
  });

  describe.each`
    featureFlag | state                                 | result
    ${true}     | ${{ isShowingEpicsSwimlanes: true }}  | ${true}
    ${true}     | ${{ isShowingEpicsSwimlanes: false }} | ${false}
    ${false}    | ${{ isShowingEpicsSwimlanes: true }}  | ${false}
    ${false}    | ${{ isShowingEpicsSwimlanes: false }} | ${false}
  `('with featureFlag=$featureFlag and state=$state', ({ featureFlag, state, result }) => {
    beforeEach(() => {
      gon.features.boardsWithSwimlanes = featureFlag;
      Object.assign(store.state, state);
      createComponent();
    });

    it(`renders BoardContentSidebar = ${result}`, () => {
      expect(wrapper.find(BoardContentSidebar).exists()).toBe(result);
    });
  });
});
