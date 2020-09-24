import { shallowMount } from '@vue/test-utils';

import geoNodeItemComponent from 'ee/geo_nodes/components/geo_node_item.vue';
import GeoNodeDetails from 'ee/geo_nodes/components/geo_node_details.vue';
import eventHub from 'ee/geo_nodes/event_hub';
import { mockNode, mockNodeDetails } from '../mock_data';

jest.mock('ee/geo_nodes/event_hub');

describe('GeoNodeItemComponent', () => {
  let wrapper;

  const defaultProps = {
    node: mockNode,
    primaryNode: true,
    nodeActionsAllowed: true,
    nodeEditAllowed: true,
    nodeRemovalAllowed: true,
    geoTroubleshootingHelpPath: '/foo/bar',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(geoNodeItemComponent, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  const findGeoNodeDetails = () => wrapper.find(GeoNodeDetails);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('data', () => {
    it('returns default data props', () => {
      expect(wrapper.vm.isNodeDetailsLoading).toBe(true);
      expect(wrapper.vm.nodeHealthStatus).toBe('');
      expect(typeof wrapper.vm.nodeDetails).toBe('object');
    });
  });

  describe('methods', () => {
    describe('handleNodeDetails', () => {
      describe('with matching ID', () => {
        beforeEach(() => {
          const mockNodeSecondary = { ...mockNode, id: mockNodeDetails.id, primary: false };

          createComponent({ node: mockNodeSecondary });
        });

        it('intializes props based on provided `nodeDetails`', () => {
          // With altered mock data with matching ID
          wrapper.vm.handleNodeDetails(mockNodeDetails);

          expect(wrapper.vm.isNodeDetailsLoading).toBeFalsy();
          expect(wrapper.vm.nodeDetails).toBe(mockNodeDetails);
          expect(wrapper.vm.nodeHealthStatus).toBe(mockNodeDetails.health);
        });
      });

      describe('without matching ID', () => {
        it('intializes props based on provided `nodeDetails`', () => {
          // With default mock data without matching ID
          wrapper.vm.handleNodeDetails(mockNodeDetails);

          expect(wrapper.vm.isNodeDetailsLoading).toBeTruthy();
          expect(wrapper.vm.nodeDetails).not.toBe(mockNodeDetails);
          expect(wrapper.vm.nodeHealthStatus).not.toBe(mockNodeDetails.health);
        });
      });
    });

    describe('handleMounted', () => {
      it('emits `pollNodeDetails` event and passes node ID', () => {
        wrapper.vm.handleMounted();

        expect(eventHub.$emit).toHaveBeenCalledWith('pollNodeDetails', wrapper.vm.node);
      });
    });
  });

  describe('created', () => {
    it('binds `nodeDetailsLoaded` event handler', () => {
      expect(eventHub.$on).toHaveBeenCalledWith('nodeDetailsLoaded', expect.any(Function));
    });
  });

  describe('beforeDestroy', () => {
    it('unbinds `nodeDetailsLoaded` event handler', () => {
      wrapper.destroy();

      expect(eventHub.$off).toHaveBeenCalledWith('nodeDetailsLoaded', expect.any(Function));
    });
  });

  describe('template', () => {
    it('renders container element', () => {
      expect(wrapper.classes('card')).toBeTruthy();
    });

    describe('when isNodeDetailsLoading is true', () => {
      beforeEach(() => {
        wrapper.setData({ isNodeDetailsLoading: true });
      });

      it('does not render details section', () => {
        expect(findGeoNodeDetails().exists()).toBeFalsy();
      });
    });

    describe('when isNodeDetailsLoading is false', () => {
      beforeEach(() => {
        wrapper.setData({ isNodeDetailsLoading: false });
      });

      it('renders details section', () => {
        expect(findGeoNodeDetails().exists()).toBeTruthy();
      });
    });
  });
});
