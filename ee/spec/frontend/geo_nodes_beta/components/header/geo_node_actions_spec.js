import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeActions from 'ee/geo_nodes_beta/components/header/geo_node_actions.vue';
import GeoNodeActionsDesktop from 'ee/geo_nodes_beta/components/header/geo_node_actions_desktop.vue';
import GeoNodeActionsMobile from 'ee/geo_nodes_beta/components/header/geo_node_actions_mobile.vue';
import { REMOVE_NODE_MODAL_ID } from 'ee/geo_nodes_beta/constants';
import {
  MOCK_NODES,
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
} from 'ee_jest/geo_nodes_beta/mock_data';
import waitForPromises from 'helpers/wait_for_promises';
import { BV_SHOW_MODAL } from '~/lib/utils/constants';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeActions', () => {
  let wrapper;

  const actionSpies = {
    prepNodeRemoval: jest.fn(),
  };

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (initialState, props) => {
    const store = new Vuex.Store({
      state: {
        primaryVersion: MOCK_PRIMARY_VERSION.version,
        primaryRevision: MOCK_PRIMARY_VERSION.revision,
        replicableTypes: MOCK_REPLICABLE_TYPES,
        ...initialState,
      },
      actions: actionSpies,
    });

    wrapper = shallowMount(GeoNodeActions, {
      localVue,
      store,
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoMobileActions = () => wrapper.findComponent(GeoNodeActionsMobile);
  const findGeoDesktopActions = () => wrapper.findComponent(GeoNodeActionsDesktop);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders mobile actions with correct visibility class always', () => {
      expect(findGeoMobileActions().exists()).toBe(true);
      expect(findGeoMobileActions().classes()).toStrictEqual(['gl-lg-display-none']);
    });

    it('renders desktop actions with correct visibility class always', () => {
      expect(findGeoDesktopActions().exists()).toBe(true);
      expect(findGeoDesktopActions().classes()).toStrictEqual([
        'gl-display-none',
        'gl-lg-display-flex',
      ]);
    });
  });

  describe('events', () => {
    describe('remove', () => {
      beforeEach(() => {
        createComponent();
        jest.spyOn(wrapper.vm.$root, '$emit');
      });

      it('preps node for removal and opens model after promise returns on desktop', async () => {
        findGeoDesktopActions().vm.$emit('remove');

        expect(actionSpies.prepNodeRemoval).toHaveBeenCalledWith(
          expect.any(Object),
          MOCK_NODES[0].id,
        );

        expect(wrapper.vm.$root.$emit).not.toHaveBeenCalledWith(
          BV_SHOW_MODAL,
          REMOVE_NODE_MODAL_ID,
        );

        await waitForPromises();

        expect(wrapper.vm.$root.$emit).toHaveBeenCalledWith(BV_SHOW_MODAL, REMOVE_NODE_MODAL_ID);
      });

      it('preps node for removal and opens model after promise returns on mobile', async () => {
        findGeoMobileActions().vm.$emit('remove');

        expect(actionSpies.prepNodeRemoval).toHaveBeenCalledWith(
          expect.any(Object),
          MOCK_NODES[0].id,
        );

        expect(wrapper.vm.$root.$emit).not.toHaveBeenCalledWith(
          BV_SHOW_MODAL,
          REMOVE_NODE_MODAL_ID,
        );

        await waitForPromises();

        expect(wrapper.vm.$root.$emit).toHaveBeenCalledWith(BV_SHOW_MODAL, REMOVE_NODE_MODAL_ID);
      });
    });
  });
});
