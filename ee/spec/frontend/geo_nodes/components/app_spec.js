import MockAdapter from 'axios-mock-adapter';
import Vue from 'vue';

import appComponent from 'ee/geo_nodes/components/app.vue';
import { NODE_ACTIONS } from 'ee/geo_nodes/constants';
import eventHub from 'ee/geo_nodes/event_hub';
import GeoNodesService from 'ee/geo_nodes/service/geo_nodes_service';
import GeoNodesStore from 'ee/geo_nodes/store/geo_nodes_store';
import mountComponent from 'helpers/vue_mount_component_helper';
import axios from '~/lib/utils/axios_utils';
import { BV_SHOW_MODAL, BV_HIDE_MODAL } from '~/lib/utils/constants';
import '~/vue_shared/plugins/global_toast';

import {
  PRIMARY_VERSION,
  NODE_DETAILS_PATH,
  mockNodes,
  mockNode,
  rawMockNodeDetails,
  MOCK_REPLICABLE_TYPES,
} from '../mock_data';

jest.mock('~/smart_interval');
jest.mock('ee/geo_nodes/event_hub');

const createComponent = () => {
  const Component = Vue.extend(appComponent);
  const store = new GeoNodesStore(
    PRIMARY_VERSION.version,
    PRIMARY_VERSION.revision,
    MOCK_REPLICABLE_TYPES,
  );
  const service = new GeoNodesService(NODE_DETAILS_PATH);

  return mountComponent(Component, {
    store,
    service,
    nodeActionsAllowed: true,
    nodeEditAllowed: true,
    geoTroubleshootingHelpPath: '/foo/bar',
  });
};

const getToastMessage = () => document.querySelector('.gl-toast').innerText.trim();
const cleanupToastMessage = () => document.querySelector('.gl-toast').remove();

describe('AppComponent', () => {
  let vm;
  let mock;
  let statusCode;
  let response;

  beforeEach(() => {
    statusCode = 200;
    response = mockNodes;

    mock = new MockAdapter(axios);

    document.body.innerHTML += '<div class="flash-container"></div>';

    mock.onGet(/(.*)\/geo_nodes$/).reply(() => [statusCode, response]);
    vm = createComponent();
  });

  afterEach(() => {
    document.querySelector('.flash-container').remove();
    vm.$destroy();
    mock.restore();
  });

  describe('data', () => {
    it('returns default data props', () => {
      expect(vm.isLoading).toBe(true);
      expect(vm.hasError).toBe(false);
      expect(vm.targetNode).toBeNull();
      expect(vm.targetNodeActionType).toBe('');
      expect(vm.modalKind).toBe('warning');
      expect(vm.modalMessage).toBe('');
      expect(vm.modalActionLabel).toBe('');
      expect(vm.modalTitle).toBe('');
      expect(vm.modalId).toBe('node-action');
    });
  });

  describe('computed', () => {
    describe('nodes', () => {
      it('returns list of nodes from store', () => {
        expect(Array.isArray(vm.nodes)).toBeTruthy();
      });
    });
  });

  describe('methods', () => {
    describe('setNodeActionStatus', () => {
      it('sets `nodeActionActive` property with value of `status` parameter for provided `node` parameter', () => {
        const node = {
          nodeActionActive: false,
        };
        vm.setNodeActionStatus(node, true);

        expect(node.nodeActionActive).toBe(true);
      });
    });

    describe('initNodeDetailsPolling', () => {
      it('initializes SmartInterval and sets it to component', () => {
        vm.initNodeDetailsPolling(2);

        expect(vm.nodePollingInterval).toBeDefined();
      });
    });

    describe('fetchGeoNodes', () => {
      it('calls service.getGeoNodes and sets response to the store on success', (done) => {
        jest.spyOn(vm.store, 'setNodes');

        vm.fetchGeoNodes()
          .then(() => {
            expect(vm.store.setNodes).toHaveBeenCalledWith(mockNodes);
            expect(vm.isLoading).toBe(false);
          })
          .then(done)
          .catch(done.fail);
      });

      it('sets error flag and message on failure', (done) => {
        response = 'Something went wrong';
        statusCode = 500;

        vm.fetchGeoNodes()
          .then(() => {
            expect(vm.isLoading).toBe(false);
            expect(document.querySelector('.flash-text').innerText.trim()).toBe(
              'Something went wrong while fetching nodes',
            );
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('fetchNodeDetails', () => {
      it('calls service.getGeoNodeDetails and sets response to the store on success', (done) => {
        mock.onGet(mockNode.statusPath).reply(200, rawMockNodeDetails);

        vm.fetchNodeDetails(mockNode)
          .then(() => {
            expect(Object.keys(vm.store.state.nodeDetails).length).not.toBe(0);
            expect(vm.store.state.nodeDetails['1']).toBeDefined();
          })
          .then(done)
          .catch(done.fail);
      });

      it('emits `nodeDetailsLoaded` event with fake nodeDetails object on 404 failure', (done) => {
        mock.onGet(mockNode.statusPath).reply(404, {});
        jest.spyOn(vm.service, 'getGeoNodeDetails');

        vm.fetchNodeDetails(mockNode)
          .then(() => {
            expect(eventHub.$emit).toHaveBeenCalledWith('nodeDetailsLoaded', expect.any(Object));
            const nodeDetails = vm.store.state.nodeDetails['1'];

            expect(nodeDetails).toBeDefined();
            expect(nodeDetails.syncStatusUnavailable).toBe(true);
            expect(nodeDetails.health).toBe('Request failed with status code 404');
          })
          .then(done)
          .catch(done.fail);
      });

      it('emits `nodeDetailsLoaded` event with fake nodeDetails object when a network error occurs', (done) => {
        mock.onGet(mockNode.statusPath).networkError();
        jest.spyOn(vm.service, 'getGeoNodeDetails');

        vm.fetchNodeDetails(mockNode)
          .then(() => {
            expect(eventHub.$emit).toHaveBeenCalledWith('nodeDetailsLoaded', expect.any(Object));
            const nodeDetails = vm.store.state.nodeDetails['1'];

            expect(nodeDetails).toBeDefined();
            expect(nodeDetails.syncStatusUnavailable).toBe(true);
            expect(nodeDetails.health).toBe('Network Error');
          })
          .then(done)
          .catch(done.fail);
      });

      it('emits `nodeDetailsLoaded` event with fake nodeDetails object when a timeout occurs', (done) => {
        mock.onGet(mockNode.statusPath).timeout();
        jest.spyOn(vm.service, 'getGeoNodeDetails');

        vm.fetchNodeDetails(mockNode)
          .then(() => {
            expect(eventHub.$emit).toHaveBeenCalledWith('nodeDetailsLoaded', expect.any(Object));
            const nodeDetails = vm.store.state.nodeDetails['1'];

            expect(nodeDetails).toBeDefined();
            expect(nodeDetails.syncStatusUnavailable).toBe(true);
            expect(nodeDetails.health).toBe('timeout of 0ms exceeded');
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('repairNode', () => {
      it('calls service.repairNode and shows success Toast message on request success', (done) => {
        const node = { ...mockNode };
        mock.onPost(node.repairPath).reply(() => {
          expect(node.nodeActionActive).toBe(true);
          return [200];
        });
        jest.spyOn(vm.service, 'repairNode');

        vm.repairNode(node)
          .then(() => {
            expect(vm.service.repairNode).toHaveBeenCalledWith(node);
            expect(getToastMessage()).toBe('Node Authentication was successfully repaired.');
            cleanupToastMessage();

            expect(node.nodeActionActive).toBe(false);
          })
          .then(done)
          .catch(done.fail);
      });

      it('calls service.repairNode and shows failure Flash message on request failure', (done) => {
        const node = { ...mockNode };
        mock.onPost(node.repairPath).reply(() => {
          expect(node.nodeActionActive).toBe(true);
          return [500];
        });
        jest.spyOn(vm.service, 'repairNode');

        vm.repairNode(node)
          .then(() => {
            expect(vm.service.repairNode).toHaveBeenCalledWith(node);
            expect(document.querySelector('.flash-text').innerText.trim()).toBe(
              'Something went wrong while repairing node',
            );

            expect(node.nodeActionActive).toBe(false);
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('toggleNode', () => {
      it('calls service.toggleNode for enabling node and updates toggle button on request success', (done) => {
        const node = { ...mockNode };
        mock.onPut(node.basePath).reply(() => {
          expect(node.nodeActionActive).toBe(true);
          return [
            200,
            {
              enabled: true,
            },
          ];
        });
        jest.spyOn(vm.service, 'toggleNode');
        node.enabled = false;

        vm.toggleNode(node)
          .then(() => {
            expect(vm.service.toggleNode).toHaveBeenCalledWith(node);
            expect(node.enabled).toBe(true);
            expect(node.nodeActionActive).toBe(false);
          })
          .then(done)
          .catch(done.fail);
      });

      it('calls service.toggleNode and shows Flash error on request failure', (done) => {
        const node = { ...mockNode };
        mock.onPut(node.basePath).reply(() => {
          expect(node.nodeActionActive).toBe(true);
          return [500];
        });
        jest.spyOn(vm.service, 'toggleNode');
        node.enabled = false;

        vm.toggleNode(node)
          .then(() => {
            expect(vm.service.toggleNode).toHaveBeenCalledWith(node);
            expect(document.querySelector('.flash-text').innerText.trim()).toBe(
              'Something went wrong while changing node status',
            );

            expect(node.nodeActionActive).toBe(false);
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('removeNode', () => {
      it('calls service.removeNode for removing node and shows Toast message on request success', (done) => {
        const node = { ...mockNode };
        mock.onDelete(node.basePath).reply(() => {
          expect(node.nodeActionActive).toBe(true);
          return [200];
        });
        jest.spyOn(vm.service, 'removeNode');
        jest.spyOn(vm.store, 'removeNode');

        vm.removeNode(node)
          .then(() => {
            expect(vm.service.removeNode).toHaveBeenCalledWith(node);
            expect(vm.store.removeNode).toHaveBeenCalledWith(node);
            expect(getToastMessage()).toBe('Node was successfully removed.');
            cleanupToastMessage();
          })
          .then(done)
          .catch(done.fail);
      });

      it('calls service.removeNode and shows Flash message on request failure', (done) => {
        const node = { ...mockNode };
        mock.onDelete(node.basePath).reply(() => {
          expect(node.nodeActionActive).toBe(true);
          return [500];
        });
        jest.spyOn(vm.service, 'removeNode');
        jest.spyOn(vm.store, 'removeNode');

        vm.removeNode(node)
          .then(() => {
            expect(vm.service.removeNode).toHaveBeenCalledWith(node);
            expect(vm.store.removeNode).not.toHaveBeenCalled();
            expect(document.querySelector('.flash-text').innerText.trim()).toBe(
              'Something went wrong while removing node',
            );
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('handleNodeAction', () => {
      it('calls `toggleNode` and `hideNodeActionModal` when `targetNodeActionType` is `toggle`', () => {
        vm.targetNode = { ...mockNode };
        vm.targetNodeActionType = NODE_ACTIONS.TOGGLE;
        jest.spyOn(vm, 'hideNodeActionModal');
        jest.spyOn(vm, 'toggleNode');

        vm.handleNodeAction();

        expect(vm.hideNodeActionModal).toHaveBeenCalled();
        expect(vm.toggleNode).toHaveBeenCalledWith(vm.targetNode);
      });

      it('calls `removeNode` and `hideNodeActionModal` when `targetNodeActionType` is `remove`', () => {
        vm.targetNode = { ...mockNode };
        vm.targetNodeActionType = NODE_ACTIONS.REMOVE;
        jest.spyOn(vm, 'hideNodeActionModal');
        jest.spyOn(vm, 'removeNode');

        vm.handleNodeAction();

        expect(vm.hideNodeActionModal).toHaveBeenCalled();
        expect(vm.removeNode).toHaveBeenCalledWith(vm.targetNode);
      });
    });

    describe('showNodeActionModal', () => {
      let node;
      let modalKind;
      let modalMessage;
      let modalActionLabel;
      let modalTitle;
      let rootEmit;

      beforeEach(() => {
        node = { ...mockNode };
        modalKind = 'warning';
        modalMessage = 'Foobar message';
        modalActionLabel = 'Disable';
        modalTitle = 'Test title';
        rootEmit = jest.spyOn(vm.$root, '$emit');
      });

      it('sets target node and modal config props on component', () => {
        vm.showNodeActionModal({
          actionType: NODE_ACTIONS.TOGGLE,
          node,
          modalKind,
          modalMessage,
          modalActionLabel,
          modalTitle,
        });

        expect(vm.targetNode).toBe(node);
        expect(vm.targetNodeActionType).toBe(NODE_ACTIONS.TOGGLE);
        expect(vm.modalKind).toBe(modalKind);
        expect(vm.modalMessage).toBe(modalMessage);
        expect(vm.modalActionLabel).toBe(modalActionLabel);
        expect(vm.modalTitle).toBe(modalTitle);
      });

      it(`emits ${BV_SHOW_MODAL} when actionType is "toggle" and node is enabled`, () => {
        node.enabled = true;
        vm.showNodeActionModal({
          actionType: NODE_ACTIONS.TOGGLE,
          node,
          modalKind,
          modalMessage,
          modalActionLabel,
          modalTitle,
        });

        expect(rootEmit).toHaveBeenCalledWith(BV_SHOW_MODAL, vm.modalId);
      });

      it('calls toggleNode when actionType is `toggle` and node.enabled is `false`', () => {
        node.enabled = false;
        jest.spyOn(vm, 'toggleNode');

        vm.showNodeActionModal({
          actionType: NODE_ACTIONS.TOGGLE,
          node,
          modalKind,
          modalMessage,
          modalActionLabel,
          modalTitle,
        });

        expect(vm.toggleNode).toHaveBeenCalledWith(vm.targetNode);
      });

      it(`emits ${BV_SHOW_MODAL} when actionType is not "toggle"`, () => {
        node.enabled = true;
        vm.showNodeActionModal({
          actionType: NODE_ACTIONS.REMOVE,
          node,
          modalKind,
          modalMessage,
          modalActionLabel,
        });

        expect(rootEmit).toHaveBeenCalledWith(BV_SHOW_MODAL, vm.modalId);
      });
    });

    describe('hideNodeActionModal', () => {
      it(`emits ${BV_HIDE_MODAL}`, () => {
        const rootEmit = jest.spyOn(vm.$root, '$emit');
        vm.hideNodeActionModal();

        expect(rootEmit).toHaveBeenCalledWith(BV_HIDE_MODAL, vm.modalId);
      });
    });

    describe('nodeRemovalAllowed', () => {
      describe.each`
        primaryNode | nodesLength | nodeRemovalAllowed
        ${false}    | ${2}        | ${true}
        ${false}    | ${1}        | ${true}
        ${true}     | ${2}        | ${false}
        ${true}     | ${1}        | ${true}
      `(
        'with (primaryNode = $primaryNode, nodesLength = $nodesLength)',
        ({ primaryNode, nodesLength, nodeRemovalAllowed }) => {
          const testPhrasing = nodeRemovalAllowed ? 'allow' : 'disallow';
          let node;

          beforeEach(() => {
            node = { ...mockNode, primary: primaryNode };
            vm.store.state.nodes = [mockNode, node].slice(0, nodesLength);
          });

          it(`should ${testPhrasing} node removal`, () => {
            expect(vm.nodeRemovalAllowed(node)).toBe(nodeRemovalAllowed);
          });
        },
      );
    });
  });

  describe('created', () => {
    it('binds event handler for `pollNodeDetails`', () => {
      const vmX = createComponent();

      expect(eventHub.$on).toHaveBeenCalledWith('pollNodeDetails', expect.any(Function));
      expect(eventHub.$on).toHaveBeenCalledWith('showNodeActionModal', expect.any(Function));
      expect(eventHub.$on).toHaveBeenCalledWith('repairNode', expect.any(Function));
      vmX.$destroy();
    });
  });

  describe('beforeDestroy', () => {
    it('unbinds event handler for `pollNodeDetails`', () => {
      const vmX = createComponent();
      vmX.$destroy();

      expect(eventHub.$off).toHaveBeenCalledWith('pollNodeDetails', expect.any(Function));
      expect(eventHub.$off).toHaveBeenCalledWith('showNodeActionModal', expect.any(Function));
      expect(eventHub.$off).toHaveBeenCalledWith('repairNode', expect.any(Function));
    });
  });

  describe('template', () => {
    it('renders container element with class `geo-nodes-container`', () => {
      expect(vm.$el.classList.contains('geo-nodes-container')).toBe(true);
    });

    it('renders loading animation when `isLoading` is true', () => {
      vm.isLoading = true;

      expect(
        vm.$el.querySelectorAll('.loading-animation.prepend-top-20.append-bottom-20').length,
      ).not.toBe(0);
    });
  });
});
