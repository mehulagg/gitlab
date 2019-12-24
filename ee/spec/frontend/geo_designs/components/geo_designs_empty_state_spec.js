import Vuex from 'vuex';
import { createLocalVue, mount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';
import store from 'ee/geo_designs/store';
import GeoDesignsEmptyState from 'ee/geo_designs/components/geo_designs_empty_state.vue';
import { MOCK_ISSUES_SVG_PATH, MOCK_GEO_TROUBLESHOOTING_LINK } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoDesignsEmptyState', () => {
  let wrapper;

  const propsData = {
    issuesSvgPath: MOCK_ISSUES_SVG_PATH,
    geoTroubleshootingLink: MOCK_GEO_TROUBLESHOOTING_LINK,
  };

  const createComponent = () => {
    wrapper = mount(localVue.extend(GeoDesignsEmptyState), {
      sync: false,
      localVue,
      store,
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGlEmptyState = () => wrapper.find(GlEmptyState);
  const findLink = () => findGlEmptyState().find('a');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders GlEmptyState', () => {
      expect(findGlEmptyState().exists()).toBe(true);
    });

    it('Link renders', () => {
      expect(findLink().exists()).toBe(true);
    });
  });
});
