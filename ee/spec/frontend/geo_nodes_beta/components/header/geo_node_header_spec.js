import { GlButton, GlBadge } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeHeader from 'ee/geo_nodes_beta/components/header/geo_node_header.vue';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
} from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeHeader', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
    collapsed: false,
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

    wrapper = shallowMount(GeoNodeHeader, {
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

  const findHeaderCollapseButton = () => wrapper.find(GlButton);
  const findCurrentNodeBadge = () => wrapper.find(GlBadge);

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });
    });

    describe('Header Collapse Icon', () => {
      describe('when not collapsed', () => {
        beforeEach(() => {
          createComponent();
        });

        it('renders the chevron-down icon', () => {
          expect(findHeaderCollapseButton().attributes('icon')).toBe('chevron-down');
        });
      });

      describe('when collapsed', () => {
        beforeEach(() => {
          createComponent(null, { collapsed: true });
        });

        it('renders the chevron-right icon', () => {
          expect(findHeaderCollapseButton().attributes('icon')).toBe('chevron-right');
        });
      });

      describe('on click', () => {
        beforeEach(() => {
          createComponent();

          findHeaderCollapseButton().vm.$emit('click');
        });

        it('emits the collapse event', () => {
          expect(wrapper.emitted('collapse')).toHaveLength(1);
        });
      });
    });

    describe('Current Node Badge', () => {
      describe('when current node is true', () => {
        beforeEach(() => {
          createComponent();
        });

        it('renders', () => {
          expect(findCurrentNodeBadge().exists()).toBe(true);
        });
      });

      describe('when current node is false', () => {
        beforeEach(() => {
          createComponent(null, { node: MOCK_NODES[1] });
        });

        it('does not render', () => {
          expect(findCurrentNodeBadge().exists()).toBe(false);
        });
      });
    });
  });
});
