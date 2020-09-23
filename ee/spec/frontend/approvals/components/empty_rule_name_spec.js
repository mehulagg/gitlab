import { shallowMount } from '@vue/test-utils';
import EmptyRuleName from 'ee/approvals/components/empty_rule_name.vue';
import { GlLink } from '@gitlab/ui';

describe('Empty Rule Name', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(EmptyRuleName, {
      propsData: {
        rule: {},
        eligibleApproversDocsPath: 'some/path',
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('has a rule name "Any eligible user"', () => {
    createComponent();

    expect(wrapper.text()).toContain('Any eligible user');
  });

  it('renders a "more information" link ', () => {
    createComponent();

    expect(wrapper.find(GlLink).attributes('href')).toBe(
      wrapper.props('eligibleApproversDocsPath'),
    );
    expect(wrapper.find(GlLink).exists()).toBe(true);
    expect(wrapper.find(GlLink).text()).toBe('More information');
  });
});
