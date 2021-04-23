import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeActionsDesktop from 'ee/geo_nodes_beta/components/header/geo_node_actions_desktop.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';

describe('GeoNodeActionsDesktop', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (props) => {
    wrapper = shallowMount(GeoNodeActionsDesktop, {
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

      it('renders edit link correctly', () => {
        expect(findGeoDesktopActionsButtons().at(0).attributes('href')).toBe(
          MOCK_NODES[0].webEditUrl,
        );
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
