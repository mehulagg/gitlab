import Vue from 'vue';

import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import geoNodesListComponent from 'ee/geo_nodes/components/geo_nodes_list.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { mockNode } from '../mock_data';

const createComponent = () => {
  const Component = Vue.extend(geoNodesListComponent);

  return mountComponent(Component, {
    nodes: [mockNode],
    nodeActionsAllowed: true,
    nodeEditAllowed: true,
  });
};

describe('GeoNodesListComponent', () => {
  let axiosMock;
  let vm;

  beforeEach(() => {
    axiosMock = new MockAdapter(axios);
    vm = createComponent();
  });

  afterEach(() => {
    vm.$destroy();
    axiosMock.restore();
  });

  describe('template', () => {
    it('renders container element correctly', () => {
      expect(vm.$el.classList.contains('card')).toBe(true);
    });
  });
});
