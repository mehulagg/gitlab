import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeActionsDesktop from 'ee/geo_nodes/components/header/geo_node_actions_desktop.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('GeoNodeActionsDesktop', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(GeoNodeActionsDesktop, {
        propsData: {
          ...defaultProps,
          ...props,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoDesktopActionsButtons = () => wrapper.findAllComponents(GlButton);
  const findGeoDesktopActionsRemoveButton = () => wrapper.findByTestId('geo-desktop-remove-action');

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

      it('renders edit link correctly', () => {
        expect(findGeoDesktopActionsButtons().at(0).attributes('href')).toBe(
          MOCK_NODES[0].webEditUrl,
        );
      });

      it('emits remove when remove button is clicked', () => {
        findGeoDesktopActionsRemoveButton().vm.$emit('click');

        expect(wrapper.emitted('remove')).toHaveLength(1);
      });
    });

    describe.each`
      primary  | disabled
      ${true}  | ${'true'}
      ${false} | ${undefined}
    `(`conditionally`, ({ primary, disabled }) => {
      beforeEach(() => {
        createComponent({ node: { primary } });
      });

      describe(`when primary is ${primary}`, () => {
        it(`does ${primary ? '' : 'not '}disable the Desktop Remove button`, () => {
          expect(findGeoDesktopActionsRemoveButton().attributes('disabled')).toBe(disabled);
        });
      });
    });
  });
});
