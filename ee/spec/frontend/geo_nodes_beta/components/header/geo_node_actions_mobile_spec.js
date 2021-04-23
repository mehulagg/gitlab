import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeActionsMobile from 'ee/geo_nodes_beta/components/header/geo_node_actions_mobile.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';

describe('GeoNodeActionsMobile', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (props) => {
    wrapper = shallowMount(GeoNodeActionsMobile, {
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

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders Dropdown', () => {
        expect(findGeoMobileActionsDropdown().exists()).toBe(true);
      });

      it('renders an Edit and Remove dropdown item', () => {
        expect(findGeoMobileActionsDropdownItems().wrappers.map((w) => w.text())).toStrictEqual([
          'Edit',
          'Remove',
        ]);
      });

      it('renders edit link correctly', () => {
        expect(findGeoMobileActionsDropdownItems().at(0).attributes('href')).toBe(
          MOCK_NODES[0].webEditUrl,
        );
      });
    });

    describe.each`
      primary  | disabled     | dropdownClass
      ${true}  | ${'true'}    | ${'gl-text-gray-400'}
      ${false} | ${undefined} | ${'gl-text-red-500'}
    `(`conditionally`, ({ primary, disabled, dropdownClass }) => {
      beforeEach(() => {
        createComponent({ node: { primary } });
      });

      describe(`when primary is ${primary}`, () => {
        it(`does ${
          primary ? '' : 'not '
        }disable the Mobile Remove dropdown item and adds proper class`, () => {
          expect(findGeoMobileActionsRemoveDropdownItem().attributes('disabled')).toBe(disabled);
          expect(findGeoMobileActionsRemoveDropdownItem().find('span').classes(dropdownClass)).toBe(
            true,
          );
        });
      });
    });
  });
});
