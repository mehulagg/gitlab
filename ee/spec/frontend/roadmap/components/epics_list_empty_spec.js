import Vue from 'vue';

import epicsListEmptyComponent from 'ee/roadmap/components/epics_list_empty.vue';

import { PRESET_TYPES } from 'ee/roadmap/constants';
import {
  getTimeframeForQuartersView,
  getTimeframeForWeeksView,
  getTimeframeForMonthsView,
} from 'ee/roadmap/utils/roadmap_utils';

import {
  mockTimeframeInitialDate,
  mockSvgPath,
  mockNewEpicEndpoint,
} from 'ee_jest/roadmap/mock_data';
import mountComponent from 'helpers/vue_mount_component_helper';

const mockTimeframeQuarters = getTimeframeForQuartersView(mockTimeframeInitialDate);
const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);
const mockTimeframeWeeks = getTimeframeForWeeksView(mockTimeframeInitialDate);

const createComponent = ({
  hasFiltersApplied = false,
  presetType = PRESET_TYPES.MONTHS,
  timeframeStart = mockTimeframeMonths[0],
  timeframeEnd = mockTimeframeMonths[mockTimeframeMonths.length - 1],
}) => {
  const Component = Vue.extend(epicsListEmptyComponent);

  return mountComponent(Component, {
    presetType,
    timeframeStart,
    timeframeEnd,
    emptyStateIllustrationPath: mockSvgPath,
    newEpicEndpoint: mockNewEpicEndpoint,
    hasFiltersApplied,
  });
};

describe('EpicsListEmptyComponent', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent({});
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('computed', () => {
    describe('message', () => {
      it('returns default empty state message', () => {
        expect(vm.message).toBe('The roadmap shows the progress of your epics along a timeline');
      });

      it('returns empty state message when `hasFiltersApplied` prop is true', done => {
        vm.hasFiltersApplied = true;
        Vue.nextTick()
          .then(() => {
            expect(vm.message).toBe('Sorry, no epics matched your search');
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('subMessage', () => {
      describe('with presetType `QUARTERS`', () => {
        beforeEach(() => {
          vm.presetType = PRESET_TYPES.QUARTERS;
          [vm.timeframeStart] = mockTimeframeQuarters;
          vm.timeframeEnd = mockTimeframeQuarters[mockTimeframeQuarters.length - 1];
        });

        it('returns default empty state sub-message when `hasFiltersApplied` props is false', done => {
          Vue.nextTick()
            .then(() => {
              expect(vm.subMessage).toBe(
                'To view the roadmap, add a start or due date to one of your epics in this group or its subgroups; from Jul 1, 2017 to Mar 31, 2019.',
              );
            })
            .then(done)
            .catch(done.fail);
        });

        it('returns empty state sub-message when `hasFiltersApplied` prop is true', done => {
          vm.hasFiltersApplied = true;
          Vue.nextTick()
            .then(() => {
              expect(vm.subMessage).toBe(
                'To widen your search, change or remove filters; from Jul 1, 2017 to Mar 31, 2019.',
              );
            })
            .then(done)
            .catch(done.fail);
        });
      });

      describe('with presetType `MONTHS`', () => {
        beforeEach(() => {
          vm.presetType = PRESET_TYPES.MONTHS;
        });

        it('returns default empty state sub-message when `hasFiltersApplied` props is false', done => {
          Vue.nextTick()
            .then(() => {
              expect(vm.subMessage).toBe(
                'To view the roadmap, add a start or due date to one of your epics in this group or its subgroups; from Nov 1, 2017 to Jun 30, 2018.',
              );
            })
            .then(done)
            .catch(done.fail);
        });

        it('returns empty state sub-message when `hasFiltersApplied` prop is true', done => {
          vm.hasFiltersApplied = true;
          Vue.nextTick()
            .then(() => {
              expect(vm.subMessage).toBe(
                'To widen your search, change or remove filters; from Nov 1, 2017 to Jun 30, 2018.',
              );
            })
            .then(done)
            .catch(done.fail);
        });
      });

      describe('with presetType `WEEKS`', () => {
        beforeEach(() => {
          const timeframeEnd = mockTimeframeWeeks[mockTimeframeWeeks.length - 1];
          timeframeEnd.setDate(timeframeEnd.getDate() + 6);

          vm.presetType = PRESET_TYPES.WEEKS;
          [vm.timeframeStart] = mockTimeframeWeeks;
          vm.timeframeEnd = timeframeEnd;
        });

        it('returns default empty state sub-message when `hasFiltersApplied` props is false', done => {
          Vue.nextTick()
            .then(() => {
              expect(vm.subMessage).toBe(
                'To view the roadmap, add a start or due date to one of your epics in this group or its subgroups; from Dec 17, 2017 to Feb 9, 2018.',
              );
            })
            .then(done)
            .catch(done.fail);
        });

        it('returns empty state sub-message when `hasFiltersApplied` prop is true', done => {
          vm.hasFiltersApplied = true;
          Vue.nextTick()
            .then(() => {
              expect(vm.subMessage).toBe(
                'To widen your search, change or remove filters; from Dec 17, 2017 to Feb 15, 2018.',
              );
            })
            .then(done)
            .catch(done.fail);
        });
      });

      describe('with child epics context', () => {
        it('returns empty state sub-message when `isChildEpics` is set to `true`', done => {
          vm.isChildEpics = true;
          Vue.nextTick()
            .then(() => {
              expect(vm.subMessage).toBe(
                'To view the roadmap, add a start or due date to one of the <a href="https://docs.gitlab.com/ee/user/group/epics/#multi-level-child-epics" target="_blank" rel="noopener noreferrer nofollow">child epics</a>.',
              );
            })
            .then(done)
            .catch(done.fail);
        });
      });
    });

    describe('timeframeRange', () => {
      it('returns correct timeframe startDate and endDate in words', () => {
        expect(vm.timeframeRange.startDate).toBe('Nov 1, 2017');
        expect(vm.timeframeRange.endDate).toBe('Jun 30, 2018');
      });
    });
  });

  describe('template', () => {
    it('renders empty state illustration in image element with provided `emptyStateIllustrationPath`', () => {
      expect(vm.$el.querySelector('.svg-content img').getAttribute('src')).toBe(
        vm.emptyStateIllustrationPath,
      );
    });

    it('renders mount point for new epic button to boot via Epic app', () => {
      expect(vm.$el.querySelector('#epic-create-root')).not.toBeNull();
    });

    it('does not render new epic button element when `hasFiltersApplied` prop is true', done => {
      vm.hasFiltersApplied = true;
      Vue.nextTick()
        .then(() => {
          expect(vm.$el.querySelector('.epic-create-dropdown')).toBeNull();
        })
        .then(done)
        .catch(done.fail);
    });

    it('renders view epics list link element', () => {
      const viewEpicsListEl = vm.$el.querySelector('a.btn');

      expect(viewEpicsListEl).not.toBeNull();
      expect(viewEpicsListEl.getAttribute('href')).toBe(mockNewEpicEndpoint);
      expect(viewEpicsListEl.querySelector('span').innerText.trim()).toBe('View epics list');
    });
  });
});
