import { GlLabel } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import ListItem from 'ee/groups/settings/compliance_framework_labels/components/list_item.vue';

describe('ListItem', () => {
  let wrapper;

  const framework = { name: 'framework', description: 'a framework', color: '#112233' };
  const findLabel = () => wrapper.find(GlLabel);
  const findDescription = () =>
    wrapper.find('[data-testid="compliance-framework-label-description"]');

  const createComponent = (props = {}) => {
    wrapper = shallowMount(ListItem, {
      propsData: {
        framework,
        ...props,
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
  });
});
