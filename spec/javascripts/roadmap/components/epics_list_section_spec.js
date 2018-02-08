import Vue from 'vue';

import epicsListSectionComponent from 'ee/roadmap/components/epics_list_section.vue';
import RoadmapStore from 'ee/roadmap/store/roadmap_store';
import eventHub from 'ee/roadmap/event_hub';
import { rawEpics, mockTimeframe, mockGroupId, mockShellWidth } from '../mock_data';

import mountComponent from '../../helpers/vue_mount_component_helper';

const store = new RoadmapStore(mockGroupId, mockTimeframe);
store.setEpics(rawEpics);
const mockEpics = store.getEpics();

const createComponent = ({
  epics = mockEpics,
  timeframe = mockTimeframe,
  currentGroupId = mockGroupId,
  shellWidth = mockShellWidth,
}) => {
  const Component = Vue.extend(epicsListSectionComponent);

  return mountComponent(Component, {
    epics,
    timeframe,
    currentGroupId,
    shellWidth,
  });
};

describe('EpicsListSectionComponent', () => {
  let vm;

  afterEach(() => {
    vm.$destroy();
  });

  describe('data', () => {
    it('returns default data props', () => {
      vm = createComponent({});
      expect(vm.shellHeight).toBe(0);
      expect(vm.emptyRowHeight).toBe(0);
      expect(vm.showEmptyRow).toBe(false);
    });
  });

  describe('computed', () => {
    beforeEach(() => {
      vm = createComponent({});
    });

    describe('calcShellWidth', () => {
      it('returns shellWidth after deducting predefined scrollbar size', () => {
        // shellWidth is 2000 (as defined above in mockShellWidth)
        // SCROLLBAR_SIZE is 15 (as defined in app's constants.js)
        // Hence, calcShellWidth = shellWidth - SCROLLBAR_SIZE
        expect(vm.calcShellWidth).toBe(1985);
      });
    });

    describe('tbodyStyles', () => {
      it('returns computed style string based on shellWidth and shellHeight', () => {
        expect(vm.tbodyStyles).toBe('width: 2015px; height: 0px;');
      });
    });

    describe('emptyRowCellStyles', () => {
      it('returns computed style string based on emptyRowHeight', () => {
        expect(vm.emptyRowCellStyles).toBe('height: 0px;');
      });
    });
  });

  describe('methods', () => {
    beforeEach(() => {
      vm = createComponent({});
    });

    describe('initMounted', () => {
      it('initializes shellHeight based on window.innerHeight and component element position', (done) => {
        vm.$nextTick(() => {
          expect(vm.shellHeight).toBe(600);
          done();
        });
      });

      it('calls initEmptyRow() when there are Epics to render', (done) => {
        spyOn(vm, 'initEmptyRow').and.callThrough();

        vm.$nextTick(() => {
          expect(vm.initEmptyRow).toHaveBeenCalled();
          done();
        });
      });

      it('emits `epicsListRendered` via eventHub', (done) => {
        spyOn(eventHub, '$emit');

        vm.$nextTick(() => {
          expect(eventHub.$emit).toHaveBeenCalledWith('epicsListRendered', jasmine.any(Object));
          done();
        });
      });
    });

    describe('initEmptyRow', () => {
      it('sets `emptyRowHeight` and `showEmptyRow` props when shellHeight is greater than approximate height of epics list', (done) => {
        vm.$nextTick(() => {
          expect(vm.emptyRowHeight).toBe(599); // total size -1px
          expect(vm.showEmptyRow).toBe(true);
          done();
        });
      });

      it('does not set `emptyRowHeight` and `showEmptyRow` props when shellHeight is less than approximate height of epics list', (done) => {
        const initialHeight = window.innerHeight;
        window.innerHeight = 0;
        const vmMoreEpics = createComponent({
          epics: mockEpics.concat(mockEpics).concat(mockEpics),
        });
        vmMoreEpics.$nextTick(() => {
          expect(vmMoreEpics.emptyRowHeight).toBe(0);
          expect(vmMoreEpics.showEmptyRow).toBe(false);
          window.innerHeight = initialHeight; // reset to prevent any side effects
          done();
        });
      });
    });

    describe('handleScroll', () => {
      it('emits `epicsListScrolled` event via eventHub', () => {
        spyOn(eventHub, '$emit');
        vm.handleScroll();
        expect(eventHub.$emit).toHaveBeenCalledWith('epicsListScrolled', jasmine.any(Number), jasmine.any(Number));
      });
    });

    describe('scrollToTodayIndicator', () => {
      it('scrolls table body to put timeline today indicator in focus', () => {
        spyOn(vm.$el, 'scrollTo');
        vm.scrollToTodayIndicator();
        expect(vm.$el.scrollTo).toHaveBeenCalledWith(jasmine.any(Number), 0);
      });
    });
  });

  describe('template', () => {
    beforeEach(() => {
      vm = createComponent({});
    });

    it('renders component container element with class `epics-list-section`', (done) => {
      vm.$nextTick(() => {
        expect(vm.$el.classList.contains('epics-list-section')).toBe(true);
        done();
      });
    });

    it('renders component container element with `width` and `left` properties applied via style attribute', (done) => {
      vm.$nextTick(() => {
        expect(vm.$el.getAttribute('style')).toBe('width: 2015px; height: 0px;');
        done();
      });
    });
  });
});
