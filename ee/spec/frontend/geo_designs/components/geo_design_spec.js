import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import GeoDesign from 'ee/geo_designs/components/geo_design.vue';
import store from 'ee/geo_designs/store';
import { MOCK_BASIC_FETCH_DATA_MAP } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoDesignsApp', () => {
  let wrapper;
  const mockDesign = MOCK_BASIC_FETCH_DATA_MAP.data[0];

  const propsData = {
    name: mockDesign.name,
    projectId: mockDesign.projectId,
    syncStatus: mockDesign.state,
    lastSynced: mockDesign.lastSyncedAt,
    lastVerified: null,
    lastChecked: null,
  };

  const createComponent = () => {
    wrapper = shallowMount(localVue.extend(GeoDesign), {
      sync: false,
      localVue,
      store,
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findCard = () => wrapper.find('.card');
  const findGlLink = () => findCard().find(GlLink);
  const findCardHeader = () => findCard().find('.card-header');
  const findCardBody = () => findCard().find('.card-body');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders card', () => {
      expect(findCard().exists()).toBe(true);
    });

    it('renders card header', () => {
      expect(findCardHeader().exists()).toBe(true);
    });

    it('renders card body', () => {
      expect(findCardBody().exists()).toBe(true);
    });

    it('GlLink renders', () => {
      expect(findGlLink().exists()).toBe(true);
    });
  });
});
