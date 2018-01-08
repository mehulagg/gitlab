import Vue from 'vue';

import geoNodeSyncSettingsComponent from 'ee/geo_nodes/components/geo_node_sync_settings.vue';
import { mockNodeDetails } from '../mock_data';

import mountComponent from '../../helpers/vue_mount_component_helper';

const createComponent = (
  namespaces = mockNodeDetails.namespaces,
  lastEvent = mockNodeDetails.lastEvent,
  cursorLastEvent = mockNodeDetails.cursorLastEvent) => {
  const Component = Vue.extend(geoNodeSyncSettingsComponent);

  return mountComponent(Component, {
    namespaces,
    lastEvent,
    cursorLastEvent,
  });
};

describe('GeoNodeSyncSettingsComponent', () => {
  describe('computed', () => {
    describe('syncType', () => {
      it('returns string representing sync type', () => {
        const vm = createComponent();
        expect(vm.syncType).toBe('Selective');
        vm.$destroy();
      });
    });
  });

  describe('methods', () => {
    let vm;

    beforeEach(() => {
      vm = createComponent();
    });

    afterEach(() => {
      vm.$destroy();
    });

    describe('lagInSeconds', () => {
      it('returns string representing sync type', () => {
        expect(vm.lagInSeconds(1511255200, 1511255450)).toBe(250);
      });
    });

    describe('statusIcon', () => {
      it('returns string representing sync status icon', () => {
        expect(vm.statusIcon(250)).toBe('retry');
        expect(vm.statusIcon(3500)).toBe('warning');
        expect(vm.statusIcon(4000)).toBe('status_failed');
      });
    });

    describe('statusEventInfo', () => {
      it('returns string representing status event info', () => {
        expect(vm.statusEventInfo(3, 3, 250)).toBe('4 minutes 10 seconds (0 events)');
      });
    });

    describe('statusTooltip', () => {
      it('returns string representing status lag message', () => {
        expect(vm.statusTooltip(250)).toBe('');
        expect(vm.statusTooltip(1000)).toBe('Node is slow, overloaded, or it just recovered after an outage.');
        expect(vm.statusTooltip(4000)).toBe('Node is failing or broken.');
      });
    });
  });
});
