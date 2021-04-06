import { GlButton } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeActionsDesktop from 'ee/geo_nodes_beta/components/header/geo_node_actions_desktop.vue';
import { MOCK_PRIMARY_VERSION, MOCK_REPLICABLE_TYPES } from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeActionsDesktop', () => {
  let wrapper;

  const defaultProps = {
    primary: true,
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

    wrapper = shallowMount(GeoNodeActionsDesktop, {
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
  });

  const findGeoDesktopActionsButtons = () => wrapper.findAll(GlButton);
  const findGeoDesktopActionsRemoveButton = () =>
    wrapper.find('[data-testid="geo-desktop-remove-action"]');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders an Edit and Remove button', () => {
        expect(findGeoDesktopActionsButtons().wrappers.map((w) => w.text())).toStrictEqual([
          'Edit',
          'Remove',
        ]);
      });
    });

    describe.each`
      primary  | disabled
      ${true}  | ${'true'}
      ${false} | ${undefined}
    `(`conditionally`, ({ primary, disabled }) => {
      beforeEach(() => {
        createComponent(null, { primary });
      });

      describe(`when primary is ${primary}`, () => {
        it('disables the Desktop Remove button', () => {
          expect(findGeoDesktopActionsRemoveButton().attributes('disabled')).toBe(disabled);
        });
      });
    });
  });
});
