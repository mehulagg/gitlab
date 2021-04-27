import { GlEmptyState } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodesEmptyState from 'ee/geo_nodes_beta/components/geo_nodes_empty_state.vue';
import { GEO_FEATURE_URL } from 'ee/geo_nodes_beta/constants';
import { MOCK_PRIMARY_VERSION, MOCK_REPLICABLE_TYPES, MOCK_EMPTY_STATE_SVG } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodesEmptyState', () => {
  let wrapper;

  const defaultProps = {
    svgPath: MOCK_EMPTY_STATE_SVG,
  };

  const createComponent = (initialState, props) => {
    const store = new Vuex.Store({
      state: {
        primaryVersion: MOCK_PRIMARY_VERSION.version,
        primaryRevision: MOCK_PRIMARY_VERSION.revision,
        replicableTypes: MOCK_REPLICABLE_TYPES,
        ...initialState,
      },
    });

    wrapper = shallowMount(GeoNodesEmptyState, {
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

  const findGeoEmptyState = () => wrapper.findComponent(GlEmptyState);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the Geo Empty State always', () => {
      expect(findGeoEmptyState().exists()).toBe(true);
    });

    it('adds the correct SVG', () => {
      expect(findGeoEmptyState().attributes('svgpath')).toBe(MOCK_EMPTY_STATE_SVG);
    });

    it('links the correct help link', () => {
      expect(findGeoEmptyState().attributes('primarybuttontext')).toBe('Learn more about Geo');
      expect(findGeoEmptyState().attributes('primarybuttonlink')).toBe(GEO_FEATURE_URL);
    });
  });
});
