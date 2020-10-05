import Vue from 'vue';

import GeoNodeHeaderComponent from 'ee/geo_nodes/components/geo_node_header.vue';
import mountComponent from 'helpers/vue_mount_component_helper';
import { mockNode, mockNodeDetails } from '../mock_data';

const createComponent = ({
  node = { ...mockNode },
  nodeDetails = { ...mockNodeDetails },
  nodeDetailsLoading = false,
  nodeDetailsFailed = false,
}) => {
  const Component = Vue.extend(GeoNodeHeaderComponent);

  return mountComponent(Component, {
    node,
    nodeDetails,
    nodeDetailsLoading,
    nodeDetailsFailed,
  });
};

describe('GeoNodeHeader', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent({});
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('computed', () => {
    describe('isNodeHTTP', () => {
      it('returns `true` when Node URL protocol is non-HTTPS', () => {
        expect(vm.isNodeHTTP).toBe(true);
      });

      it('returns `false` when Node URL protocol is HTTPS', done => {
        vm.node.url = 'https://127.0.0.1:3001/';
        Vue.nextTick()
          .then(() => {
            expect(vm.isNodeHTTP).toBe(false);
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe.each`
      nodeDetailsLoading | url                         | showWarning
      ${false}           | ${'https://127.0.0.1:3001'} | ${false}
      ${false}           | ${'http://127.0.0.1:3001'}  | ${true}
      ${true}            | ${'https://127.0.0.1:3001'} | ${false}
      ${true}            | ${'http://127.0.0.1:3001'}  | ${false}
    `(`showNodeWarningIcon`, ({ nodeDetailsLoading, url, showWarning }) => {
      beforeEach(() => {
        vm.nodeDetailsLoading = nodeDetailsLoading;
        vm.node.url = url;
      });

      it(`should return ${showWarning}`, () => {
        expect(vm.showNodeWarningIcon).toBe(showWarning);
      });

      it(`should ${showWarning ? 'render' : 'not render'} the status icon`, () => {
        expect(Boolean(vm.$el.querySelector('[data-testid="warning-icon"]'))).toBe(showWarning);
      });
    });
  });

  describe('template', () => {
    it('renders node name element', () => {
      expect(vm.$el.innerText).toContain(vm.node.name);
    });
  });
});
