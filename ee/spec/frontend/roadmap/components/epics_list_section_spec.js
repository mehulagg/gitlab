import { shallowMount, createLocalVue } from '@vue/test-utils';
import VirtualList from 'vue-virtual-scroll-list';
import EpicsListSection from 'ee/roadmap/components/epics_list_section.vue';
import EpicItem from 'ee/roadmap/components/epic_item.vue';
import createStore from 'ee/roadmap/store';
import { getTimeframeForMonthsView } from 'ee/roadmap/utils/roadmap_utils';
import {
  PRESET_TYPES,
  EPIC_DETAILS_CELL_WIDTH,
  TIMELINE_CELL_MIN_WIDTH,
} from 'ee/roadmap/constants';
import {
  mockFormattedChildEpic1,
  mockFormattedChildEpic2,
  mockTimeframeInitialDate,
  mockGroupId,
  rawEpics,
  mockSortedBy,
  basePath,
  epicsPath,
} from 'ee_jest/roadmap/mock_data';

const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);
const store = createStore();
store.dispatch('setInitialData', {
  currentGroupId: mockGroupId,
  sortedBy: mockSortedBy,
  presetType: PRESET_TYPES.MONTHS,
  timeframe: mockTimeframeMonths,
  filterQueryString: '',
  initialEpicsPath: epicsPath,
  basePath,
});

store.dispatch('receiveEpicsSuccess', { rawEpics });

const mockEpics = store.state.epics;

store.state.epics[0].children = {
  edges: [mockFormattedChildEpic1, mockFormattedChildEpic2],
};
const localVue = createLocalVue();

const createComponent = ({
  epics = mockEpics,
  timeframe = mockTimeframeMonths,
  currentGroupId = mockGroupId,
  presetType = PRESET_TYPES.MONTHS,
  roadmapBufferedRendering = true,
} = {}) => {
  return shallowMount(EpicsListSection, {
    localVue,
    store,
    stubs: {
      EpicItem: false,
      VirtualList: false,
    },
    propsData: {
      presetType,
      epics,
      timeframe,
      currentGroupId,
    },
    provide: {
      glFeatures: { roadmapBufferedRendering },
    },
  });
};

describe('EpicsListSectionComponent', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('data', () => {
    it('returns default data props', () => {
      // Destroy the existing wrapper, and create a new one. This works around
      // a race condition between how Jest runs tests and the $nextTick call in
      // EpicsListSectionComponent's mounted hook.
      // https://gitlab.com/gitlab-org/gitlab/-/merge_requests/27992#note_319213990
      wrapper.destroy();
      wrapper = createComponent();

      expect(wrapper.vm.offsetLeft).toBe(0);
      expect(wrapper.vm.emptyRowContainerStyles).toEqual({});
      expect(wrapper.vm.showBottomShadow).toBe(false);
      expect(wrapper.vm.roadmapShellEl).toBeDefined();
    });
  });

  describe('computed', () => {
    describe('emptyRowContainerVisible', () => {
      it('returns true when total epics are less than buffer size', () => {
        wrapper.vm.setBufferSize(wrapper.vm.epics.length + 1);

        expect(wrapper.vm.emptyRowContainerVisible).toBe(true);
      });
    });

    describe('sectionContainerStyles', () => {
      it('returns style string for container element based on sectionShellWidth', () => {
        expect(wrapper.vm.sectionContainerStyles.width).toBe(
          `${EPIC_DETAILS_CELL_WIDTH + TIMELINE_CELL_MIN_WIDTH * wrapper.vm.timeframe.length}px`,
        );
      });
    });

    describe('shadowCellStyles', () => {
      it('returns computed style object based on `offsetLeft` prop value', () => {
        expect(wrapper.vm.shadowCellStyles.left).toBe('0px');
      });
    });
  });

  describe('methods', () => {
    describe('initMounted', () => {
      beforeEach(() => {
        // Destroy the existing wrapper, and create a new one. This works
        // around a race condition between how Jest runs tests and the
        // $nextTick call in EpicsListSectionComponent's mounted hook.
        // https://gitlab.com/gitlab-org/gitlab/-/merge_requests/27992#note_319213990
        wrapper.destroy();
        wrapper = createComponent();

        jest.spyOn(wrapper.vm, 'scrollToTodayIndicator').mockImplementation(() => {});
      });

      it('sets value of `roadmapShellEl` with root component element', () => {
        expect(wrapper.vm.roadmapShellEl instanceof HTMLElement).toBe(true);
      });

      it('calls action `setBufferSize` with value based on window.innerHeight and component element position', () => {
        expect(wrapper.vm.bufferSize).toBe(16);
      });

      it('sets value of `offsetLeft` with parentElement.offsetLeft', () => {
        return wrapper.vm.$nextTick(() => {
          // During tests, there's no `$el.parentElement` present
          // hence offsetLeft is 0.
          expect(wrapper.vm.offsetLeft).toBe(0);
        });
      });

      it('calls `scrollToTodayIndicator` following the component render', () => {
        // Original method implementation waits for render cycle
        // to complete at 2 levels before scrolling.
        return wrapper.vm
          .$nextTick()
          .then(() => wrapper.vm.$nextTick())
          .then(() => {
            expect(wrapper.vm.scrollToTodayIndicator).toHaveBeenCalled();
          });
      });

      it('sets style object to `emptyRowContainerStyles`', () => {
        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.emptyRowContainerStyles).toEqual(
            expect.objectContaining({
              height: '0px',
            }),
          );
        });
      });
    });

    describe('getEmptyRowContainerStyles', () => {
      it('returns empty object when there are no epics available to render', () => {
        wrapper.setProps({
          epics: [],
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.getEmptyRowContainerStyles()).toEqual({});
        });
      });

      it('returns object containing `height` when there epics available to render', () => {
        expect(wrapper.vm.getEmptyRowContainerStyles()).toEqual(
          expect.objectContaining({
            height: '0px',
          }),
        );
      });
    });

    describe('handleEpicsListScroll', () => {
      it('toggles value of `showBottomShadow` based on provided `scrollTop`, `clientHeight` & `scrollHeight`', () => {
        wrapper.vm.handleEpicsListScroll({
          scrollTop: 5,
          clientHeight: 5,
          scrollHeight: 15,
        });

        // Math.ceil(scrollTop) + clientHeight < scrollHeight
        expect(wrapper.vm.showBottomShadow).toBe(true);

        wrapper.vm.handleEpicsListScroll({
          scrollTop: 15,
          clientHeight: 5,
          scrollHeight: 15,
        });

        // Math.ceil(scrollTop) + clientHeight < scrollHeight
        expect(wrapper.vm.showBottomShadow).toBe(false);
      });
    });

    describe('getEpicItemProps', () => {
      it('returns an object containing props for EpicItem component', () => {
        expect(wrapper.vm.getEpicItemProps(1)).toEqual(
          expect.objectContaining({
            key: 1,
            props: {
              epic: wrapper.vm.epics[1],
              presetType: wrapper.vm.presetType,
              timeframe: wrapper.vm.timeframe,
              currentGroupId: wrapper.vm.currentGroupId,
            },
          }),
        );
      });
    });
  });

  describe('template', () => {
    it('renders component container element with class `epics-list-section`', () => {
      expect(wrapper.classes('epics-list-section')).toBe(true);
    });

    it('renders virtual-list when roadmapBufferedRendering is `true` and `epics.length` is more than `bufferSize`', () => {
      wrapper.vm.setBufferSize(5);

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.find(VirtualList).exists()).toBe(true);
      });
    });

    it('renders epic-item when roadmapBufferedRendering is `false`', () => {
      // Destroy the wrapper created in the beforeEach above
      wrapper.destroy();

      const wrapperFlagOff = createComponent({
        roadmapBufferedRendering: false,
      });

      expect(wrapperFlagOff.find(EpicItem).exists()).toBe(true);

      wrapperFlagOff.destroy();
    });

    it('renders epic-item when roadmapBufferedRendering is `true` and `epics.length` is less than `bufferSize`', () => {
      wrapper.vm.setBufferSize(50);

      expect(wrapper.find(EpicItem).exists()).toBe(true);
    });

    it('renders empty row element when `epics.length` is less than `bufferSize`', () => {
      wrapper.vm.setBufferSize(50);

      expect(wrapper.find('.epics-list-item-empty').exists()).toBe(true);
    });

    it('renders bottom shadow element when `showBottomShadow` prop is true', () => {
      wrapper.setData({
        showBottomShadow: true,
      });

      expect(wrapper.find('.epic-scroll-bottom-shadow').exists()).toBe(true);
    });
  });

  it('expands to show child epics when epic is toggled', done => {
    const epic = mockEpics[0];

    expect(wrapper.findAll(EpicItem).length).toBe(mockEpics.length);

    wrapper.vm.toggleIsEpicExpanded(epic.id);

    wrapper.vm
      .$nextTick()
      .then(() => {
        const expected = mockEpics.length + epic.children.edges.length;

        expect(wrapper.findAll(EpicItem).length).toBe(expected);
      })
      .then(done)
      .catch(done.fail);
  });
});
