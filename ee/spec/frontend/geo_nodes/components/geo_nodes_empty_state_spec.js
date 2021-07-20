import { GlEmptyState } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodesEmptyState from 'ee/geo_nodes/components/geo_nodes_empty_state.vue';
import { GEO_FEATURE_URL } from 'ee/geo_nodes/constants';
import { MOCK_EMPTY_STATE_SVG } from '../mock_data';

describe('GeoNodesEmptyState', () => {
  let wrapper;

  const defaultProps = {
    svgPath: MOCK_EMPTY_STATE_SVG,
  };

  const createComponent = (props) => {
    wrapper = shallowMount(GeoNodesEmptyState, {
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
