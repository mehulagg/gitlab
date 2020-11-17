import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';
import createStore from 'ee/geo_replicable/store';
import GeoReplicableEmptyState from 'ee/geo_replicable/components/geo_replicable_empty_state.vue';
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

  const createComponent = () => {
    wrapper = shallowMount(GeoReplicableEmptyState, {
      localVue,
      store: createStore({ replicableType: MOCK_REPLICABLE_TYPE, graphqlFieldName: null }),
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGlEmptyState = () => wrapper.find(GlEmptyState);

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
});
