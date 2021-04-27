import { GlLink, GlButton, GlLoadingIcon } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodesBetaApp from 'ee/geo_nodes_beta/components/app.vue';
import GeoNodes from 'ee/geo_nodes_beta/components/geo_nodes.vue';
import GeoNodesEmptyState from 'ee/geo_nodes_beta/components/geo_nodes_empty_state.vue';
import { GEO_INFO_URL } from 'ee/geo_nodes_beta/constants';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
  MOCK_NEW_NODE_URL,
  MOCK_EMPTY_STATE_SVG,
} from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodesBetaApp', () => {
  let wrapper;

  const actionSpies = {
    fetchNodes: jest.fn(),
  };

  const defaultProps = {
    newNodeUrl: MOCK_NEW_NODE_URL,
    geoNodesEmptyStateSvg: MOCK_EMPTY_STATE_SVG,
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

    wrapper = shallowMount(GeoNodesBetaApp, {
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

  const findGeoNodesBetaContainer = () => wrapper.find('section');
  const findGeoLearnMoreLink = () => wrapper.findComponent(GlLink);
  const findGeoAddSiteButton = () => wrapper.findComponent(GlButton);
  const findGlLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findGeoEmptyState = () => wrapper.findComponent(GeoNodesEmptyState);
  const findGeoNodes = () => wrapper.findAllComponents(GeoNodes);

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the Geo Nodes Beta Container', () => {
        expect(findGeoNodesBetaContainer().exists()).toBe(true);
      });

      it('renders the Learn more link correctly', () => {
        expect(findGeoLearnMoreLink().exists()).toBe(true);
        expect(findGeoLearnMoreLink().attributes('href')).toBe(GEO_INFO_URL);
      });
    });

    describe.each`
      isLoading | nodes         | showLoadingIcon | showNodes | showEmptyState | showAddButton
      ${true}   | ${[]}         | ${true}         | ${false}  | ${false}       | ${false}
      ${true}   | ${MOCK_NODES} | ${true}         | ${false}  | ${false}       | ${true}
      ${false}  | ${[]}         | ${false}        | ${false}  | ${true}        | ${false}
      ${false}  | ${MOCK_NODES} | ${false}        | ${true}   | ${false}       | ${true}
    `(
      `conditionally`,
      ({ isLoading, nodes, showLoadingIcon, showNodes, showEmptyState, showAddButton }) => {
        beforeEach(() => {
          createComponent({ isLoading, nodes });
        });

        describe(`when isLoading is ${isLoading} & nodes length ${nodes.length}`, () => {
          it(`does ${showLoadingIcon ? '' : 'not '}render GlLoadingIcon`, () => {
            expect(findGlLoadingIcon().exists()).toBe(showLoadingIcon);
          });

          it(`does ${showNodes ? '' : 'not '}render GeoNodes`, () => {
            expect(findGeoNodes().exists()).toBe(showNodes);
          });

          it(`does ${showEmptyState ? '' : 'not '}render EmptyState`, () => {
            expect(findGeoEmptyState().exists()).toBe(showEmptyState);
          });

          it(`does ${showAddButton ? '' : 'not '}render AddSiteButton`, () => {
            expect(findGeoAddSiteButton().exists()).toBe(showAddButton);
          });
        });
      },
    );

    describe('with Geo Nodes', () => {
      beforeEach(() => {
        createComponent({ nodes: MOCK_NODES });
      });

      it('renders a Geo Node component for each node', () => {
        expect(findGeoNodes()).toHaveLength(MOCK_NODES.length);
      });
    });
  });

  describe('onCreate', () => {
    beforeEach(() => {
      createComponent();
    });

    it('calls fetchNodes', () => {
      expect(actionSpies.fetchNodes).toHaveBeenCalledTimes(1);
    });
  });
});
