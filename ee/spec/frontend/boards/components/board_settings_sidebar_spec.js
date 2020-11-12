import '~/boards/models/list';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';
import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import BoardSettingsWipLimit from 'ee_component/boards/components/board_settings_wip_limit.vue';
import BoardSettingsListTypes from 'ee_component/boards/components/board_settings_list_types.vue';
import BoardSettingsSidebar from '~/boards/components/board_settings_sidebar.vue';
import boardsStore from '~/boards/stores/boards_store';
import getters from '~/boards/stores/getters';
import { LIST } from '~/boards/constants';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('ee/BoardSettingsSidebar', () => {
  let wrapper;
  let storeActions;
  const labelTitle = 'test';
  const labelColor = '#FFFF';
  const listId = 1;
  let mock;

  const createComponent = (actions = {}, isWipLimitsOn = false) => {
    storeActions = actions;

    const store = new Vuex.Store({
      state: { sidebarType: LIST, activeId: listId },
      getters,
      actions: storeActions,
    });

    wrapper = shallowMount(BoardSettingsSidebar, {
      store,
      localVue,
      provide: {
        glFeatures: {
          wipLimits: isWipLimitsOn,
        },
      },
      stubs: {
        'board-settings-sidebar-wip-limit': BoardSettingsWipLimit,
        'board-settings-list-types': BoardSettingsListTypes,
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    boardsStore.create();
  });

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
  });

  it('confirms we render BoardSettingsSidebarWipLimit', () => {
    boardsStore.addList({
      id: listId,
      label: { title: labelTitle, color: labelColor },
      max_issue_count: 0,
      list_type: 'label',
    });

    createComponent({}, true);

    expect(wrapper.find(BoardSettingsWipLimit).exists()).toBe(true);
  });

  it('confirms we render BoardSettingsListTypes', () => {
    boardsStore.addList({
      id: 1,
      milestone: {
        webUrl: 'https://gitlab.com/h5bp/html5-boilerplate/-/milestones/1',
        title: 'Backlog',
      },
      max_issue_count: 1,
      list_type: 'milestone',
    });

    createComponent();

    expect(wrapper.find(BoardSettingsListTypes).exists()).toBe(true);
  });
});
