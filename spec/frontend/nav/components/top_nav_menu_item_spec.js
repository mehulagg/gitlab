import { GlButton, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import TopNavMenuItem from '~/nav/components/top_nav_menu_item.vue';

const TEST_MENU_ITEM = {
  title: 'Cheeseburger',
  icon: 'search',
  href: '/pretty/good/burger',
  data: { qa_selector: 'not-a-real-selector', method: 'post', testFoo: 'test' },
};

describe('~/nav/components/top_nav_menu_item.vue', () => {
  let listener;
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(TopNavMenuItem, {
      propsData: {
        menuItem: TEST_MENU_ITEM,
        ...props,
      },
      listeners: {
        click: listener,
      },
    });
  };

  const findButton = () => wrapper.find(GlButton);
  const findButtonIcons = () =>
    findButton()
      .findAllComponents(GlIcon)
      .wrappers.map((x) => ({
        name: x.props('name'),
        classes: x.classes(),
      }));

  beforeEach(() => {
    listener = jest.fn();
  });

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders button href and text', () => {
      const button = findButton();

      expect(button.attributes('href')).toBe(TEST_MENU_ITEM.href);
      expect(button.text()).toBe(TEST_MENU_ITEM.title);
    });

    it('renders button data attributes', () => {
      const button = findButton();

      expect(button.attributes()).toMatchObject({
        'data-qa-selector': TEST_MENU_ITEM.data.qa_selector,
        'data-method': TEST_MENU_ITEM.data.method,
        'data-test-foo': TEST_MENU_ITEM.data.testFoo,
      });
    });

    it('passes listeners to button', () => {
      expect(listener).not.toHaveBeenCalled();

      findButton().vm.$emit('click', 'TEST');

      expect(listener).toHaveBeenCalledWith('TEST');
    });
  });

  describe('with icon-only', () => {
    beforeEach(() => {
      createComponent({ iconOnly: true, menuItem: { ...TEST_MENU_ITEM, view: 'test-view' } });
    });

    it('does not render title or view icon', () => {
      expect(wrapper.text()).toBe('');
    });

    it('only renders menuItem icon', () => {
      expect(findButtonIcons()).toEqual([
        {
          name: TEST_MENU_ITEM.icon,
          classes: [],
        },
      ]);
    });
  });

  describe.each`
    desc              | menuItem                                    | expectedIcons
    ${'default'}      | ${{ ...TEST_MENU_ITEM }}                    | ${[TEST_MENU_ITEM.icon]}
    ${'with no icon'} | ${{ ...TEST_MENU_ITEM, icon: null }}        | ${[]}
    ${'with view'}    | ${{ ...TEST_MENU_ITEM, view: 'test-view' }} | ${[TEST_MENU_ITEM.icon, 'chevron-right']}
  `('$desc', ({ menuItem, expectedIcons }) => {
    beforeEach(() => {
      createComponent({ menuItem });
    });

    it(`renders expected icons ${JSON.stringify(expectedIcons)}`, () => {
      expect(findButtonIcons().map((x) => x.name)).toEqual(expectedIcons);
    });
  });

  describe.each`
    desc                         | menuItem                                              | expectedClasses
    ${'default'}                 | ${{}}                                                 | ${[]}
    ${'with css class'}          | ${{ css_class: 'test-css-class testing-123' }}        | ${['test-css-class', 'testing-123']}
    ${'with css class & active'} | ${{ css_class: 'test-css-class', active: true }}      | ${['test-css-class', ...TopNavMenuItem.ACTIVE_CLASS.split(' ')]}
    ${'with css class & view'}   | ${{ css_class: 'test-css-class', view: 'test-view' }} | ${['test-css-class', 'gl-pr-3!']}
  `('$desc', ({ menuItem, expectedClasses }) => {
    beforeEach(() => {
      createComponent({
        menuItem: {
          ...TEST_MENU_ITEM,
          ...menuItem,
        },
      });
    });

    it('renders expected classes', () => {
      expect(wrapper.classes()).toStrictEqual([
        'top-nav-menu-item',
        'gl-display-block',
        ...expectedClasses,
      ]);
    });
  });
});
