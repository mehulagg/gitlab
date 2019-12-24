import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import GeoDesignsApp from 'ee/geo_designs/components/app.vue';
import store from 'ee/geo_designs/store';
import GeoDesignsDisabled from 'ee/geo_designs/components/geo_designs_disabled.vue';
import GeoDesigns from 'ee/geo_designs/components/geo_designs.vue';
import GeoDesignsEmptyState from 'ee/geo_designs/components/geo_designs_empty_state.vue';
import GeoDesignsFilterBar from 'ee/geo_designs/components/geo_designs_filter_bar.vue';
import {
  MOCK_GEO_SVG_PATH,
  MOCK_ISSUES_SVG_PATH,
  MOCK_GEO_TROUBLESHOOTING_LINK,
  MOCK_DESIGN_MANAGEMENT_LINK,
  MOCK_BASIC_FETCH_DATA_MAP,
} from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoDesignsApp', () => {
  let wrapper;

  const propsData = {
    geoSvgPath: MOCK_GEO_SVG_PATH,
    issuesSvgPath: MOCK_ISSUES_SVG_PATH,
    geoTroubleshootingLink: MOCK_GEO_TROUBLESHOOTING_LINK,
    designManagementLink: MOCK_DESIGN_MANAGEMENT_LINK,
  };

  const actionSpies = {
    fetchDesigns: jest.fn(),
    setEndpoint: jest.fn(),
  };

  const glFeatures = {
    enableGeoDesignSync: true,
  };

  const createComponent = () => {
    wrapper = shallowMount(localVue.extend(GeoDesignsApp), {
      sync: false,
      localVue,
      store,
      propsData,

      methods: {
        ...actionSpies,
      },

      provide: {
        glFeatures,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoDesignsContainer = () => wrapper.find('.geo-designs-container');
  const findGeoDesignsEnabledContainer = () => findGeoDesignsContainer().find('section');
  const findGeoDesignsDisabled = () => findGeoDesignsContainer().find(GeoDesignsDisabled);
  const findGlLoadingIcon = () => findGeoDesignsContainer().find(GlLoadingIcon);
  const findGeoDesigns = () => findGeoDesignsContainer().find(GeoDesigns);
  const findGeoDesignsEmptyState = () => findGeoDesignsContainer().find(GeoDesignsEmptyState);
  const findGeoDesignsFilterBar = () => findGeoDesignsContainer().find(GeoDesignsFilterBar);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the design container', () => {
      expect(findGeoDesignsContainer().exists()).toBe(true);
    });

    describe('when designsEnabled = false', () => {
      beforeEach(() => {
        glFeatures.enableGeoDesignSync = false;
        createComponent();
      });

      it('shows designs disabled component', () => {
        expect(findGeoDesignsDisabled().exists()).toBe(true);
      });

      it('hides designs enabled container', () => {
        expect(findGeoDesignsEnabledContainer().exists()).toBe(false);
      });
    });

    describe('when designsEnabled = true', () => {
      beforeEach(() => {
        glFeatures.enableGeoDesignSync = true;
        createComponent();
      });

      it('hides designs disabled component', () => {
        expect(findGeoDesignsDisabled().exists()).toBe(false);
      });

      it('shows designs enabled container', () => {
        expect(findGeoDesignsEnabledContainer().exists()).toBe(true);
      });

      it('renders the filter bar', () => {
        expect(findGeoDesignsFilterBar().exists()).toBe(true);
      });

      describe('when isLoading = true', () => {
        beforeEach(() => {
          wrapper.vm.$store.state.isLoading = true;
        });

        it('hides designs', () => {
          expect(findGeoDesigns().exists()).toBe(false);
        });

        it('hides empty state', () => {
          expect(findGeoDesignsEmptyState().exists()).toBe(false);
        });

        it('shows loader', () => {
          expect(findGlLoadingIcon().exists()).toBe(true);
        });
      });

      describe('when isLoading = false', () => {
        beforeEach(() => {
          wrapper.vm.$store.state.isLoading = false;
        });

        describe('with designs', () => {
          beforeEach(() => {
            wrapper.vm.$store.state.designs = MOCK_BASIC_FETCH_DATA_MAP.data;
            wrapper.vm.$store.state.totalDesigns = MOCK_BASIC_FETCH_DATA_MAP.total;
          });

          it('shows designs', () => {
            expect(findGeoDesigns().exists()).toBe(true);
          });

          it('hides empty state', () => {
            expect(findGeoDesignsEmptyState().exists()).toBe(false);
          });

          it('hides loader', () => {
            expect(findGlLoadingIcon().exists()).toBe(false);
          });
        });

        describe('with no designs', () => {
          beforeEach(() => {
            wrapper.vm.$store.state.designs = [];
            wrapper.vm.$store.state.totalDesigns = 0;
          });

          it('hides designs', () => {
            expect(findGeoDesigns().exists()).toBe(false);
          });

          it('shows empty state', () => {
            expect(findGeoDesignsEmptyState().exists()).toBe(true);
          });

          it('hides loader', () => {
            expect(findGlLoadingIcon().exists()).toBe(false);
          });
        });
      });
    });
  });

  describe('onCreate', () => {
    beforeEach(() => {
      createComponent();
    });

    it('calls fetchDesigns', () => {
      expect(actionSpies.fetchDesigns).toHaveBeenCalled();
    });
  });
});
