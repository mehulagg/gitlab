import Vuex from 'vuex';
import { createLocalVue, mount } from '@vue/test-utils';
import { GlButton, GlEmptyState } from '@gitlab/ui';
import GeoDesignsDisabled from 'ee/geo_designs/components/geo_designs_disabled.vue';
import store from 'ee/geo_designs/store';
import {
  MOCK_GEO_SVG_PATH,
  MOCK_GEO_TROUBLESHOOTING_LINK,
  MOCK_DESIGN_MANAGEMENT_LINK,
} from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoDesignsDisabled', () => {
  let wrapper;

  const propsData = {
    geoSvgPath: MOCK_GEO_SVG_PATH,
    geoTroubleshootingLink: MOCK_GEO_TROUBLESHOOTING_LINK,
    designManagementLink: MOCK_DESIGN_MANAGEMENT_LINK,
  };

  const createComponent = () => {
    wrapper = mount(localVue.extend(GeoDesignsDisabled), {
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
  const findGlButton = () => findGlEmptyState().findAll(GlButton);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders GlEmptyState', () => {
      expect(findGlEmptyState().exists()).toEqual(true);
    });

    it('renders 2 GlButtons', () => {
      expect(findGlButton().length).toEqual(2);
    });
  });
});
