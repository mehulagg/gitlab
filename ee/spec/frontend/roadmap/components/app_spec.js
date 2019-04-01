import Vue from 'vue';

import appComponent from 'ee/roadmap/components/app.vue';
import createStore from 'ee/roadmap/store';
import eventHub from 'ee/roadmap/event_hub';

import { getTimeframeForMonthsView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES, EXTEND_AS } from 'ee/roadmap/constants';

import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import {
  mockTimeframeInitialDate,
  mockGroupId,
  mockNewEpicEndpoint,
  rawEpics,
  mockSvgPath,
  mockSortedBy,
  basePath,
  epicsPath,
} from '../mock_data';

const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);

const createComponent = () => {
  const Component = Vue.extend(appComponent);

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

  return mountComponentWithStore(Component, {
    store,
    props: {
      presetType: PRESET_TYPES.MONTHS,
      hasFiltersApplied: true,
      newEpicEndpoint: mockNewEpicEndpoint,
      emptyStateIllustrationPath: mockSvgPath,
    },
  });
};

describe('AppComponent', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent();
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('data', () => {
    it('returns default data props', () => {
      expect(vm.handleResizeThrottled).toBeDefined();
    });
  });

  describe('computed', () => {
    describe('timeframeStart', () => {
      it('returns first item of timeframe array', () => {
        expect(vm.timeframeStart instanceof Date).toBe(true);
      });
    });

    describe('timeframeEnd', () => {
      it('returns last item of timeframe array', () => {
        expect(vm.timeframeEnd instanceof Date).toBe(true);
      });
    });

    describe('showRoadmap', () => {
      it('returns true if `epicsFetchInProgress`, `epicsFetchResultEmpty` and `epicsFetchFailure` are all `false`', () => {
        vm.$store.state.epicsFetchInProgress = false;
        vm.$store.state.epicsFetchResultEmpty = false;
        vm.$store.state.epicsFetchFailure = false;

        expect(vm.showRoadmap).toBe(true);
      });

      it('returns false if either of `epicsFetchInProgress`, `epicsFetchResultEmpty` and `epicsFetchFailure` is `true`', () => {
        vm.$store.state.epicsFetchInProgress = true;
        vm.$store.state.epicsFetchResultEmpty = false;
        vm.$store.state.epicsFetchFailure = false;

        expect(vm.showRoadmap).toBe(false);
        vm.$store.state.epicsFetchInProgress = false;
        vm.$store.state.epicsFetchResultEmpty = true;
        vm.$store.state.epicsFetchFailure = false;

        expect(vm.showRoadmap).toBe(false);
        vm.$store.state.epicsFetchInProgress = false;
        vm.$store.state.epicsFetchResultEmpty = false;
        vm.$store.state.epicsFetchFailure = true;

        expect(vm.showRoadmap).toBe(false);
      });
    });
  });

  describe('methods', () => {
    describe('processExtendedTimeline', () => {
      it('updates timeline by extending timeframe from the start when called with extendType as `prepend`', done => {
        vm.$store.dispatch('receiveEpicsSuccess', { rawEpics });
        vm.$store.state.epicsFetchInProgress = false;

        Vue.nextTick()
          .then(() => {
            const roadmapTimelineEl = vm.$el.querySelector('.roadmap-timeline-section');

            jest.spyOn(eventHub, '$emit').mockImplementation(() => {});
            jest.spyOn(roadmapTimelineEl.parentElement, 'scrollBy').mockImplementation(() => {});

            vm.processExtendedTimeline({
              extendType: EXTEND_AS.PREPEND,
              roadmapTimelineEl,
              itemsCount: 0,
            });

            expect(eventHub.$emit).toHaveBeenCalledWith('refreshTimeline', jasmine.any(Object));
            expect(roadmapTimelineEl.parentElement.scrollBy).toHaveBeenCalled();
          })
          .then(done)
          .catch(done.fail);
      });

      it('updates timeline by extending timeframe from the end when called with extendType as `append`', done => {
        vm.$store.dispatch('receiveEpicsSuccess', { rawEpics });
        vm.$store.state.epicsFetchInProgress = false;

        Vue.nextTick()
          .then(() => {
            const roadmapTimelineEl = vm.$el.querySelector('.roadmap-timeline-section');

            jest.spyOn(eventHub, '$emit').mockImplementation(() => {});

            vm.processExtendedTimeline({
              extendType: EXTEND_AS.PREPEND,
              roadmapTimelineEl,
              itemsCount: 0,
            });

            expect(eventHub.$emit).toHaveBeenCalledWith('refreshTimeline', jasmine.any(Object));
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('handleScrollToExtend', () => {
      let roadmapTimelineEl;

      beforeAll(() => {
        vm.$store.dispatch('receiveEpicsSuccess', { rawEpics });
        vm.$store.state.epicsFetchInProgress = false;
        roadmapTimelineEl = vm.$el.querySelector('.roadmap-timeline-section');
      });

      it('updates the store and refreshes roadmap with extended timeline based on provided extendType', () => {
        jest.spyOn(vm, 'extendTimeframe').mockImplementation(() => {});
        jest.spyOn(vm, 'refreshEpicDates').mockImplementation(() => {});

        const extendType = EXTEND_AS.PREPEND;

        vm.handleScrollToExtend(roadmapTimelineEl, extendType);

        expect(vm.extendTimeframe).toHaveBeenCalledWith({ extendAs: extendType });
        expect(vm.refreshEpicDates).toHaveBeenCalled();
      });

      it('calls `fetchEpicsForTimeframe` with extended timeframe array', done => {
        jest.spyOn(vm, 'extendTimeframe').mockImplementation(() => {});
        jest.spyOn(vm, 'refreshEpicDates').mockImplementation(() => {});
        jest.spyOn(vm, 'fetchEpicsForTimeframe').mockImplementation(() => Promise.resolve());

        const extendType = EXTEND_AS.PREPEND;

        vm.handleScrollToExtend(roadmapTimelineEl, extendType);

        vm.$nextTick()
          .then(() => {
            expect(vm.fetchEpicsForTimeframe).toHaveBeenCalledWith(
              jasmine.objectContaining({
                timeframe: vm.extendedTimeframe,
              }),
            );
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });

  describe('mounted', () => {
    it('binds window resize event listener', () => {
      jest.spyOn(window, 'addEventListener').mockImplementation(() => {});
      const vmX = createComponent();

      expect(vmX.handleResizeThrottled).toBeDefined();
      expect(window.addEventListener).toHaveBeenCalledWith(
        'resize',
        vmX.handleResizeThrottled,
        false,
      );
      vmX.$destroy();
    });
  });

  describe('beforeDestroy', () => {
    it('unbinds window resize event listener', () => {
      jest.spyOn(window, 'removeEventListener').mockImplementation(() => {});
      const vmX = createComponent();
      vmX.$destroy();

      expect(window.removeEventListener).toHaveBeenCalledWith(
        'resize',
        vmX.handleResizeThrottled,
        false,
      );
    });
  });

  describe('template', () => {
    it('renders roadmap container with class `roadmap-container`', () => {
      expect(vm.$el.classList.contains('roadmap-container')).toBe(true);
    });

    it('renders roadmap container with classes `roadmap-container overflow-reset` when isEpicsListEmpty prop is true', done => {
      vm.$store.state.epicsFetchResultEmpty = true;
      Vue.nextTick()
        .then(() => {
          expect(vm.$el.classList.contains('roadmap-container')).toBe(true);
          expect(vm.$el.classList.contains('overflow-reset')).toBe(true);
        })
        .then(done)
        .catch(done.fail);
    });
  });
});
