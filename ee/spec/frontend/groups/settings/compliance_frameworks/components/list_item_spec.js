import { GlLabel } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import ListItem from 'ee/groups/settings/compliance_frameworks/components/list_item.vue';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';

describe('ListItem', () => {
  let wrapper;

  const framework = { name: 'framework', description: 'a framework', color: '#112233' };
  const findLabel = () => wrapper.find(GlLabel);
  const findDescription = () => wrapper.find('[data-testid="compliance-framework-description"]');
  const findDeleteButton = () => wrapper.find('[data-testid="compliance-framework-delete-button"]');

  const createComponent = (props = {}) => {
    wrapper = shallowMount(ListItem, {
      propsData: {
        framework,
        loading: false,
        ...props,
      },
      directives: {
        GlTooltip: createMockDirective(),
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('displays the description defined by the framework', () => {
    createComponent();

    expect(findDescription().text()).toBe('a framework');
  });

  it('displays the label as unscoped', () => {
    createComponent();

    expect(findLabel().props('title')).toBe('framework');
    expect(findLabel().props('scoped')).toBe(false);
  });

  it('displays the label as scoped', () => {
    createComponent({ framework: { ...framework, name: 'scoped::framework' } });

    expect(findLabel().props('title')).toBe('scoped::framework');
    expect(findLabel().props('scoped')).toBe(true);
    expect(findLabel().props('disabled')).toBe(false);
  });

  it('displays a delete button', () => {
    createComponent();

    const button = findDeleteButton();
    const tooltip = getBinding(button.element, 'gl-tooltip');

    expect(button.props('icon')).toBe('remove');
    expect(button.props('disabled')).toBe(false);
    expect(button.props('loading')).toBe(false);
    expect(button.attributes('aria-label')).toBe('Delete framework');
    expect(tooltip.value).toBe('Delete framework');
  });

  it('emits "delete" event when the delete button is clicked', async () => {
    createComponent();

    findDeleteButton().vm.$emit('click');

    expect(wrapper.emitted('delete')[0]).toStrictEqual([framework]);
  });

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ loading: true });
    });

    it('disables the label', () => {
      expect(findLabel().props('disabled')).toBe(true);
    });

    it('disables the delete button and shows loading', () => {
      expect(findDeleteButton().props('disabled')).toBe(true);
      expect(findDeleteButton().props('loading')).toBe(true);
    });
  });
});
