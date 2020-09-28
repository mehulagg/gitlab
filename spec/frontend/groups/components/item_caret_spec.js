import { shallowMount } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import ItemCaret from '~/groups/components/item_caret.vue';

describe('ItemCaret', () => {
  let wrapper;

  const defaultProps = {
    isGroupOpen: false,
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMount(ItemCaret, {
      propsData: { ...defaultProps, ...props },
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findAllGlIcons = () => wrapper.findAll(GlIcon);
  const findGlIcon = () => wrapper.find(GlIcon);

  describe('template', () => {
    it('should render component template correctly', () => {
      createComponent();

      expect(wrapper.classes()).toContain('folder-caret');
      expect(findAllGlIcons()).toHaveLength(1);
    });

    it('should render caret down icon if `isGroupOpen` prop is `true`', () => {
      createComponent({
        isGroupOpen: true,
      });

      expect(findGlIcon().props('name')).toBe('angle-down');
    });

    it('should render caret right icon if `isGroupOpen` prop is `false`', () => {
      createComponent();

      expect(findGlIcon().props('name')).toBe('angle-right');
    });
  });
});
