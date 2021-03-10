import { GlDropdown, GlDropdownItem, GlButton } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeActions from 'ee/geo_nodes_beta/components/header/geo_node_actions.vue';
import { MOCK_PRIMARY_VERSION, MOCK_REPLICABLE_TYPES } from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeActions', () => {
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

    wrapper = shallowMount(GeoNodeActions, {
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

  const findGeoMobileActionsDropdown = () => wrapper.find(GlDropdown);
  const findGeoMobileActionsDropdownItems = () => wrapper.findAll(GlDropdownItem);
  const findGeoMobileActionsRemoveDropdownItem = () =>
    wrapper.find('[data-testid="geo-mobile-remove-action"]');
  const findGeoDesktopActions = () => wrapper.find('[data-testid="geo-desktop-actions"]');
  const findGeoDesktopActionsButtons = () => wrapper.findAll(GlButton);
  const findGeoDesktopActionsRemoveButton = () =>
    wrapper.find('[data-testid="geo-desktop-remove-action"]');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      describe('for Mobile Actions', () => {
        it('renders Dropdown with correct visibility class', () => {
          expect(findGeoMobileActionsDropdown().exists()).toBe(true);
          expect(findGeoMobileActionsDropdown().classes()).toStrictEqual(['gl-lg-display-none']);
        });

        it('renders an Edit and Remove dropdown item', () => {
          expect(findGeoMobileActionsDropdownItems().wrappers.map((w) => w.text())).toStrictEqual([
            'Edit',
            'Remove',
          ]);
        });
      });

      describe('for Desktop Actions', () => {
        it('renders container with correct visibility class', () => {
          expect(findGeoDesktopActions().exists()).toBe(true);
          expect(findGeoDesktopActions().classes()).toStrictEqual([
            'gl-display-none',
            'gl-lg-display-flex',
          ]);
        });

        it('renders an Edit and Remove button', () => {
          expect(findGeoDesktopActionsButtons().wrappers.map((w) => w.text())).toStrictEqual([
            'Edit',
            'Remove',
          ]);
        });
      });
    });

    describe.each`
      primary  | disabled     | dropdownClass
      ${true}  | ${'true'}    | ${'gl-text-gray-400'}
      ${false} | ${undefined} | ${'gl-text-red-500'}
    `(`conditionally`, ({ primary, disabled, dropdownClass }) => {
      beforeEach(() => {
        createComponent(null, { primary });
      });

      describe(`when primary is ${primary}`, () => {
        it('disables the Mobile Remove dropdown item', () => {
          expect(findGeoMobileActionsRemoveDropdownItem().attributes('disabled')).toBe(disabled);
        });

        it('adds disabled class to the Mobile Remove dropdown item', () => {
          expect(findGeoMobileActionsRemoveDropdownItem().find('span').classes(dropdownClass)).toBe(
            true,
          );
        });

        it('disables the Desktop Remove button', () => {
          expect(findGeoDesktopActionsRemoveButton().attributes('disabled')).toBe(disabled);
        });
      });
    });
  });
});
