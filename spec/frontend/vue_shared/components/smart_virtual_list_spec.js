import { mount, createLocalVue } from '@vue/test-utils';
import SmartVirtualScrollList from '~/vue_shared/components/smart_virtual_list.vue';

const localVue = createLocalVue();

const ItemComponent = {
  props: {
    index: { type: Number, required: true },
    source: { type: Object, required: false, default: () => ({}) },
  },
  template: `<li data-testid="smart-virtual-list-item">{{ index }} - {{ source.text }}</li>`,
};

describe('Toggle Button', () => {
  let wrapper;

  const findVirtualList = () => wrapper.find('[data-testid="smart-virtual-list"]');
  const findVirtualListItems = () => wrapper.findAll('[data-testid="smart-virtual-list-item"]');

  const findPlainList = () => wrapper.find('[data-testid="smart-virtual-list-plain"]');
  const findPlainListWrapper = () =>
    wrapper.find('[data-testid="smart-virtual-list-plain-wrapper"]');
  const findPlainListItemByKey = key =>
    wrapper.find(`[data-testid="smart-virtual-list-plain-item-${key}"]`);

  const createComponent = props => {
    wrapper = mount(SmartVirtualScrollList, {
      localVue,
      propsData: {
        dataKey: 'id',
        dataComponent: ItemComponent,
        dataSources: [],
        ...props,
      },
      stubs: {
        ItemComponent,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('if the list is shorter than the maximum shown elements', () => {
    const dataSources = [{ id: 1, text: 'one' }, { id: 2, text: 'two' }];

    beforeEach(() => {
      createComponent({
        dataSources,
        rootTag: 'section',
        wrapTag: 'ul',
        wrapClass: 'test-class',
      });
    });

    it('renders without the vue-virtual-scroll-list component', () => {
      expect(findVirtualList().exists()).toBe(false);
      expect(findPlainList().exists()).toBe(true);
    });

    it('renders list with provided tags and classes for the wrapper elements', () => {
      expect(findPlainList().element.tagName).toEqual('SECTION');
      expect(findPlainListWrapper().element.tagName).toEqual('UL');
      expect(findPlainListWrapper().classes()).toContain('test-class');
    });

    it.each(dataSources)('renders item component for %s', source => {
      expect(findPlainListItemByKey(source.id).exists()).toBe(true);
    });
  });

  describe('if the list is longer than the maximum shown elements', () => {
    const dataSources = [
      { id: 1, text: 'one' },
      { id: 2, text: 'two' },
      { id: 3, text: 'three' },
      { id: 4, text: 'four' },
      { id: 5, text: 'five' },
      { id: 6, text: 'six' },
    ];

    const maxItemsShown = 1;

    beforeEach(() => {
      createComponent({
        dataSources,
        keeps: maxItemsShown,
      });
    });

    it('uses the vue-virtual-scroll-list component', () => {
      expect(findVirtualList().exists()).toBe(true);
      expect(findPlainList().exists()).toBe(false);
    });

    it('renders at max twice the maximum shown elements', () => {
      expect(findVirtualListItems().length).toBeGreaterThan(0);
      expect(findVirtualListItems().length).toBeLessThanOrEqual(2 * maxItemsShown);
    });
  });
});
