import { shallowMount } from '@vue/test-utils';
import GeoNodeActionsComponent from 'ee/geo_nodes/components/geo_node_actions.vue';
import { GlButton } from '@gitlab/ui';
import eventHub from 'ee/geo_nodes/event_hub';
import { NODE_ACTIONS } from 'ee/geo_nodes/constants';
import { mockNodes } from '../mock_data';

jest.mock('ee/geo_nodes/event_hub');

describe('GeoNodeActionsComponent', () => {
  let wrapper;

  const defaultProps = {
    node: mockNodes[0],
    nodeEditAllowed: true,
    nodeActionsAllowed: true,
    nodeRemovalAllowed: true,
    nodeMissingOauth: false,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(GeoNodeActionsComponent, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGeoNodeActionsComponent = () => wrapper.find('[data-testid="nodeActions"]');
  const findNodeActions = () => wrapper.findAll(GlButton);
  const findRemoveButton = () => wrapper.find('[data-testid="removeButton"]');

  describe('computed', () => {
    describe('disabledRemovalTooltip', () => {
      describe.each`
        nodeRemovalAllowed | tooltip
        ${true}            | ${''}
        ${false}           | ${'Cannot remove a primary node if there is a secondary node'}
      `('when nodeRemovalAllowed is $nodeRemovalAllowed', ({ nodeRemovalAllowed, tooltip }) => {
        beforeEach(() => {
          createComponent({ nodeRemovalAllowed });
        });

        it('renders the correct tooltip', () => {
          const tip = wrapper.vm.$el.querySelector('div[name=disabledRemovalTooltip]');
          expect(tip.title).toBe(tooltip);
        });
      });
    });
  });

  describe('methods', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('onRemovePrimaryNode', () => {
      it('emits showNodeActionModal with actionType `remove`, node reference, modalKind, modalMessage, modalActionLabel, and modalTitle', () => {
        wrapper.vm.onRemovePrimaryNode();

        expect(eventHub.$emit).toHaveBeenCalledWith('showNodeActionModal', {
          actionType: NODE_ACTIONS.REMOVE,
          node: wrapper.vm.node,
          modalKind: 'danger',
          modalMessage:
            'Removing a Geo primary node stops the synchronization to all nodes. Are you sure?',
          modalActionLabel: 'Remove node',
          modalTitle: 'Remove primary node',
        });
      });
    });

    describe('onRemoveSecondaryNode', () => {
      it('emits showNodeActionModal with actionType `remove`, node reference, modalKind, modalMessage, modalActionLabel, and modalTitle', () => {
        wrapper.vm.onRemoveSecondaryNode();

        expect(eventHub.$emit).toHaveBeenCalledWith('showNodeActionModal', {
          actionType: NODE_ACTIONS.REMOVE,
          node: wrapper.vm.node,
          modalKind: 'danger',
          modalMessage:
            'Removing a Geo secondary node stops the synchronization to that node. Are you sure?',
          modalActionLabel: 'Remove node',
          modalTitle: 'Remove secondary node',
        });
      });
    });

    describe('onRepairNode', () => {
      it('emits `repairNode` event with node reference', () => {
        wrapper.vm.onRepairNode();

        expect(eventHub.$emit).toHaveBeenCalledWith('repairNode', wrapper.vm.node);
      });
    });
  });

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders container elements correctly', () => {
      expect(findGeoNodeActionsComponent().exists()).toBeTruthy();
      expect(findNodeActions()).not.toHaveLength(0);
    });

    describe.each`
      nodeRemovalAllowed | buttonDisabled
      ${false}           | ${'true'}
      ${true}            | ${undefined}
    `(`Remove Button`, ({ nodeRemovalAllowed, buttonDisabled }) => {
      beforeEach(() => {
        createComponent({ node: mockNodes[1], nodeRemovalAllowed });
      });

      describe(`when nodeRemovalAllowed is ${nodeRemovalAllowed}`, () => {
        it('has the correct button text', () => {
          expect(
            findRemoveButton()
              .text()
              .trim(),
          ).toBe('Remove');
        });

        it(`the button's disabled attribute should be ${buttonDisabled}`, () => {
          expect(findRemoveButton().attributes('disabled')).toBe(buttonDisabled);
        });
      });
    });
  });
});
