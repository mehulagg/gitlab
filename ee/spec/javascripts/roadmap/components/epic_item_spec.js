import Vue from 'vue';

import _ from 'lodash-es';

import epicItemComponent from 'ee/roadmap/components/epic_item.vue';

import { getTimeframeForMonthsView } from 'ee/roadmap/utils/roadmap_utils';

import { PRESET_TYPES } from 'ee/roadmap/constants';

import mountComponent from 'spec/helpers/vue_mount_component_helper';
import {
  mockTimeframeInitialDate,
  mockEpic,
  mockGroupId,
  mockShellWidth,
  mockItemWidth,
} from '../mock_data';

const mockTimeframeMonths = getTimeframeForMonthsView(mockTimeframeInitialDate);

const createComponent = ({
  presetType = PRESET_TYPES.MONTHS,
  epic = mockEpic,
  timeframe = mockTimeframeMonths,
  currentGroupId = mockGroupId,
  shellWidth = mockShellWidth,
  itemWidth = mockItemWidth,
}) => {
  const Component = Vue.extend(epicItemComponent);

  return mountComponent(Component, {
    presetType,
    epic,
    timeframe,
    currentGroupId,
    shellWidth,
    itemWidth,
  });
};

describe('EpicItemComponent', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent({});
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('methods', () => {
    describe('removeHighlight', () => {
      it('should call _.delay after 3 seconds with a callback function which would set `epic.newEpic` to false when it is true already', done => {
        spyOn(_, 'delay');

        vm.epic.newEpic = true;

        vm.removeHighlight();

        vm.$nextTick()
          .then(() => {
            expect(_.delay).toHaveBeenCalledWith(jasmine.any(Function), 3000);
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });

  describe('template', () => {
    it('renders component container element class `epics-list-item`', () => {
      expect(vm.$el.classList.contains('epics-list-item')).toBeTruthy();
    });

    it('renders Epic item details element with class `epic-details-cell`', () => {
      expect(vm.$el.querySelector('.epic-details-cell')).not.toBeNull();
    });

    it('renders Epic timeline element with class `epic-timeline-cell`', () => {
      expect(vm.$el.querySelector('.epic-timeline-cell')).not.toBeNull();
    });
  });
});
