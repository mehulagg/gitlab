import { GlDropdownItem, GlAvatar } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { MOCK_GROUPS } from 'jest/search/mock_data';
import { truncateNamespace } from '~/lib/utils/text_utility';
import SearchableDropdownItem from '~/search/topbar/components/searchable_dropdown_item.vue';
import { GROUP_DATA } from '~/search/topbar/constants';

describe('Global Search Searchable Dropdown Item', () => {
  let wrapper;

  const defaultProps = {
    item: MOCK_GROUPS[0],
    selectedItem: MOCK_GROUPS[0],
    name: GROUP_DATA.name,
    fullName: GROUP_DATA.fullName,
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(SearchableDropdownItem, {
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

  const findGlDropdownItem = () => wrapper.findComponent(GlDropdownItem);
  const findGlAvatar = () => wrapper.findComponent(GlAvatar);
  const findDropdownTitle = () => wrapper.findByTestId('item-title');
  const findDropdownSubtitle = () => wrapper.findByTestId('item-namespace');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders GlDropdownItem', () => {
        expect(findGlDropdownItem().exists()).toBe(true);
      });

      it('renders GlAvatar', () => {
        expect(findGlAvatar().exists()).toBe(true);
      });

      it('renders Dropdown Title correctly', () => {
        expect(findDropdownTitle().exists()).toBe(true);
        expect(findDropdownTitle().text()).toBe(MOCK_GROUPS[0][GROUP_DATA.name]);
      });

      it('renders Dropdown Subtitle correctly', () => {
        expect(findDropdownSubtitle().exists()).toBe(true);
        expect(findDropdownSubtitle().text()).toBe(
          truncateNamespace(MOCK_GROUPS[0][GROUP_DATA.fullName]),
        );
      });
    });

    describe('when selected', () => {
      beforeEach(() => {
        createComponent();
      });

      it('marks the dropdown as checked', () => {
        expect(findGlDropdownItem().attributes('ischecked')).toBe('true');
      });
    });

    describe('when not selected', () => {
      beforeEach(() => {
        createComponent({ selectedItem: MOCK_GROUPS[1] });
      });

      it('marks the dropdown as not checked', () => {
        expect(findGlDropdownItem().attributes('ischecked')).toBeUndefined();
      });
    });
  });

  describe('actions', () => {
    beforeEach(() => {
      createComponent();
    });

    it('clicking the dropdown item $emits @change with item', () => {
      findGlDropdownItem().vm.$emit('click');

      expect(wrapper.emitted('change')[0]).toEqual([MOCK_GROUPS[0]]);
    });
  });
});
