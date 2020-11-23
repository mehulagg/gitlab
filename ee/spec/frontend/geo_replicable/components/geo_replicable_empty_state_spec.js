import { GlEmptyState, GlLink } from '@gitlab/ui';
import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoReplicableEmptyState from 'ee/geo_replicable/components/geo_replicable_empty_state.vue';
import createStore from 'ee/geo_replicable/store';
import {
  MOCK_GEO_REPLICATION_SVG_PATH,
  MOCK_GEO_TROUBLESHOOTING_LINK,
  MOCK_REPLICABLE_TYPE,
} from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoReplicableEmptyState', () => {
  let wrapper;

  const propsData = {
    geoTroubleshootingLink: MOCK_GEO_TROUBLESHOOTING_LINK,
    geoReplicableEmptySvgPath: MOCK_GEO_REPLICATION_SVG_PATH,
  };

  const createComponent = (mountFn = shallowMount) => {
    wrapper = mountFn(GeoReplicableEmptyState, {
      localVue,
      store: createStore({ replicableType: MOCK_REPLICABLE_TYPE, graphqlFieldName: null }),
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGlEmptyState = () => wrapper.find(GlEmptyState);
  const findGlLink = () => wrapper.find(GlLink);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('GlEmptyState', () => {
      it('renders always', () => {
        expect(findGlEmptyState().exists()).toBe(true);
      });

      it('sets correct svg', () => {
        expect(findGlEmptyState().attributes('svgpath')).toBe(MOCK_GEO_REPLICATION_SVG_PATH);
      });
    });
  });

  describe('GlLink', () => {
    beforeEach(() => {
      createComponent(mount);
    });

    it('renders always', () => {
      expect(findGlLink().exists()).toBe(true);
    });

    it('renders with correct link', () => {
      expect(findGlLink().attributes('href')).toBe(MOCK_GEO_TROUBLESHOOTING_LINK);
    });
  });
});
