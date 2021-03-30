import { shallowMount } from '@vue/test-utils';
import BoardContent from '~/boards/components/board_content.vue';
import BoardContentSidebar from '~/boards/components/board_content_sidebar.vue';
import { createStore } from '~/boards/stores';

describe('ee/BoardContent', () => {
  let wrapper;
  let store;
  window.gon = { licensed_features: {} };

  const createComponent = () => {
    wrapper = shallowMount(BoardContent, {
      store,
      provide: {
        timeTrackingLimitToHours: false,
        canAdminList: false,
      },
      propsData: {
        lists: [],
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
    window.gon.licensed_features = {};
    wrapper.destroy();
  });

  describe.each`
    licenseEnabled | state                                 | result
    ${true}        | ${{ isShowingEpicsSwimlanes: true }}  | ${true}
    ${true}        | ${{ isShowingEpicsSwimlanes: false }} | ${false}
    ${false}       | ${{ isShowingEpicsSwimlanes: true }}  | ${false}
    ${false}       | ${{ isShowingEpicsSwimlanes: false }} | ${false}
  `('with licenseEnabled=$licenseEnabled and state=$state', ({ licenseEnabled, state, result }) => {
    beforeEach(() => {
      gon.licensed_features.swimlanes = licenseEnabled;
      Object.assign(store.state, state);
      createComponent();
    });

    it(`renders BoardContentSidebar = ${result}`, () => {
      expect(wrapper.find(BoardContentSidebar).exists()).toBe(result);
    });
  });
});
