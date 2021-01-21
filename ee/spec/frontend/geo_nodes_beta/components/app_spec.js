import { shallowMount } from '@vue/test-utils';
import GeoNodesBetaApp from 'ee/geo_nodes_beta/components/app.vue';

describe('GeoNodesBetaApp', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(GeoNodesBetaApp);
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGeoNodesBetaContainer = () => wrapper.find('section');

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the container always', () => {
      expect(findGeoNodesBetaContainer().exists()).toBe(true);
    });
  });
});
