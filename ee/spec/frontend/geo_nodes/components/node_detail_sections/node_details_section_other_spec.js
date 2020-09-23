import Vue from 'vue';

import NodeDetailsSectionOtherComponent from 'ee/geo_nodes/components/node_detail_sections/node_details_section_other.vue';
import mountComponent from 'helpers/vue_mount_component_helper';
import { mockNode, mockNodeDetails } from '../../mock_data';
import { numberToHumanSize } from '~/lib/utils/number_utils';

const createComponent = (
  node = { ...mockNode },
  nodeDetails = { ...mockNodeDetails },
  nodeTypePrimary = false,
) => {
  const Component = Vue.extend(NodeDetailsSectionOtherComponent);

  return mountComponent(Component, {
    node,
    nodeDetails,
    nodeTypePrimary,
  });
};

describe('NodeDetailsSectionOther', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent();
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('data', () => {
    it('returns default data props', () => {
      expect(vm.showSectionItems).toBe(false);
    });
  });

  describe('computed', () => {
    describe('nodeDetailItems', () => {
      it('returns array containing items to show under primary node when prop `nodeTypePrimary` is true', () => {
        const vmNodePrimary = createComponent(mockNode, mockNodeDetails, true);

        const items = vmNodePrimary.nodeDetailItems;

        expect(items).toHaveLength(3);
        expect(items[0].itemTitle).toBe('Replication slots');
        expect(items[0].itemValue).toBe(mockNodeDetails.replicationSlots);
        expect(items[1].itemTitle).toBe('Replication slot WAL');
        expect(items[1].itemValue).toBe(numberToHumanSize(mockNodeDetails.replicationSlotWAL));
        expect(items[2].itemTitle).toBe('Internal URL');
        expect(items[2].itemValue).toBe(mockNode.internalUrl);

        vmNodePrimary.$destroy();
      });

      it('returns array containing items to show under secondary node when prop `nodeTypePrimary` is false', () => {
        const items = vm.nodeDetailItems;

        expect(items).toHaveLength(1);
        expect(items[0].itemTitle).toBe('Storage config');
      });
    });

    describe('storageShardsStatus', () => {
      it('returns `Unknown` when `nodeDetails.storageShardsMatch` is null', done => {
        vm.nodeDetails.storageShardsMatch = null;
        Vue.nextTick()
          .then(() => {
            expect(vm.storageShardsStatus).toBe('Unknown');
          })
          .then(done)
          .catch(done.fail);
      });

      it('returns `OK` when `nodeDetails.storageShardsMatch` is true', done => {
        vm.nodeDetails.storageShardsMatch = true;
        Vue.nextTick()
          .then(() => {
            expect(vm.storageShardsStatus).toBe('OK');
          })
          .then(done)
          .catch(done.fail);
      });

      it('returns storage shard status string when `nodeDetails.storageShardsMatch` is false', () => {
        expect(vm.storageShardsStatus).toBe('Does not match the primary storage configuration');
      });
    });

    describe('storageShardsCssClass', () => {
      it('returns CSS class `font-weight-bold` when `nodeDetails.storageShardsMatch` is true', done => {
        vm.nodeDetails.storageShardsMatch = true;
        Vue.nextTick()
          .then(() => {
            expect(vm.storageShardsCssClass[0]).toBe('font-weight-bold');
            expect(vm.storageShardsCssClass[1]['text-danger-500']).toBeFalsy();
          })
          .then(done)
          .catch(done.fail);
      });

      it('returns CSS class `font-weight-bold text-danger-500` when `nodeDetails.storageShardsMatch` is false', () => {
        expect(vm.storageShardsCssClass[0]).toBe('font-weight-bold');
        expect(vm.storageShardsCssClass[1]['text-danger-500']).toBeTruthy();
      });
    });
  });

  describe('template', () => {
    it('renders component container element', () => {
      expect(vm.$el.classList.contains('other-section')).toBe(true);
    });

    it('renders show section button element', () => {
      expect(vm.$el.querySelector('.btn-link')).not.toBeNull();
      expect(vm.$el.querySelector('.btn-link > span').innerText.trim()).toBe('Other information');
    });

    it('renders section items container element', done => {
      vm.showSectionItems = true;
      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.section-items-container')).not.toBeNull();
        done();
      });
    });
  });
});
