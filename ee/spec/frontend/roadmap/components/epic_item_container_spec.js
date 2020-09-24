import { mount } from '@vue/test-utils';

import createStore from 'ee/roadmap/store';
import EpicItem from 'ee/roadmap/components/epic_item.vue';
import EpicItemContainer from 'ee/roadmap/components/epic_item_container.vue';

import { getTimeframeForMonthsView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES } from 'ee/roadmap/constants';

import {
  mockTimeframeInitialDate,
  mockGroupId,
  mockFormattedChildEpic1,
} from 'ee_jest/roadmap/mock_data';

let store;

const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);

const createComponent = ({
  presetType = PRESET_TYPES.MONTHS,
  timeframe = mockTimeframeMonths,
  currentGroupId = mockGroupId,
  children = [],
  childLevel = 0,
  childrenEpics = {},
  childrenFlags = { '1': { itemExpanded: false } },
  hasFiltersApplied = false,
} = {}) => {
  return mount(EpicItemContainer, {
    store,
    stubs: {
      'epic-item': EpicItem,
    },
    propsData: {
      presetType,
      timeframe,
      currentGroupId,
      children,
      childLevel,
      childrenEpics,
      childrenFlags,
      hasFiltersApplied,
    },
  });
};

describe('EpicItemContainer', () => {
  let wrapper;

  beforeEach(() => {
    store = createStore();
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('template', () => {
    it('renders epic list container', () => {
      expect(wrapper.classes('epic-list-item-container')).toBe(true);
    });

    it('renders one Epic item element per child', () => {
      wrapper = createComponent({
        children: [mockFormattedChildEpic1],
        childrenFlags: {
          '1': { itemExpanded: true },
          '50': { itemExpanded: false },
        },
      });
      expect(wrapper.find(EpicItem).exists()).toBe(true);
      expect(wrapper.findAll(EpicItem).length).toBe(wrapper.vm.children.length);
    });
  });
});
