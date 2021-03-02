import { GlLink, GlButton } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodesBetaApp from 'ee/geo_nodes_beta/components/app.vue';
import GeoNodes from 'ee/geo_nodes_beta/components/geo_nodes.vue';
import { GEO_INFO_URL } from 'ee/geo_nodes_beta/constants';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
  MOCK_NEW_NODE_URL,
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
    wrapper = null;
  });

  const findGeoNodesBetaContainer = () => wrapper.find('section');
  const findGeoLearnMoreLink = () => wrapper.find(GlLink);
  const findGeoAddSiteButton = () => wrapper.find(GlButton);
  const findGeoNodes = () => wrapper.findAll(GeoNodes);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the Geo Nodes Beta Container always', () => {
      expect(findGeoNodesBetaContainer().exists()).toBe(true);
    });

    it('renders the Learn more link correctly', () => {
      expect(findGeoLearnMoreLink().exists()).toBe(true);
      expect(findGeoLearnMoreLink().attributes('href')).toBe(GEO_INFO_URL);
    });

    it('renders the Add site button correctly', () => {
      expect(findGeoAddSiteButton().exists()).toBe(true);
      expect(findGeoAddSiteButton().attributes('href')).toBe(MOCK_NEW_NODE_URL);
    });
  });

  describe('Geo Nodes', () => {
    beforeEach(() => {
      createComponent({ nodes: MOCK_NODES });
    });

    it('renders a Geo Node component for each node', () => {
      expect(findGeoNodes()).toHaveLength(MOCK_NODES.length);
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
