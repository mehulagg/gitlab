import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodes from 'ee/geo_nodes_beta/components/geo_nodes.vue';
import GeoNodeHeader from 'ee/geo_nodes_beta/components/header/geo_node_header.vue';
import { MOCK_PRIMARY_VERSION, MOCK_REPLICABLE_TYPES, MOCK_NODES } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodes', () => {
  let wrapper;

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
    });

    wrapper = shallowMount(GeoNodes, {
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

  const findGeoNodesContainer = () => wrapper.find('div');
  const findGeoSiteTitle = () => wrapper.find('h4');
  const findGeoNodeHeader = () => wrapper.find(GeoNodeHeader);
  const findGeoNodeDetails = () => wrapper.find('p');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the Geo Nodes Container always', () => {
      expect(findGeoNodesContainer().exists()).toBe(true);
    });

    it('renders the Geo Node Header always', () => {
      expect(findGeoNodeHeader().exists()).toBe(true);
    });

    describe('Node Details', () => {
      it('renders by default', () => {
        expect(findGeoNodeDetails().exists()).toBe(true);
      });

      it('is hidden when toggled', () => {
        findGeoNodeHeader().vm.$emit('collapse');

        return wrapper.vm.$nextTick(() => {
          expect(findGeoNodeDetails().exists()).toBe(false);
        });
      });
    });
  });

  describe.each`
    node             | siteTitle
    ${MOCK_NODES[0]} | ${'Primary site'}
    ${MOCK_NODES[1]} | ${'Secondary site'}
  `(`Site Title`, ({ node, siteTitle }) => {
    beforeEach(() => {
      createComponent(null, { node });
    });

    it(`is ${siteTitle} when primary is ${node.primary}`, () => {
      expect(findGeoSiteTitle().exists()).toBe(true);
      expect(findGeoSiteTitle().text()).toBe(siteTitle);
    });
  });
});
