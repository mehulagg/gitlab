import { shallowMount } from '@vue/test-utils';
import RuleBranches from 'ee/approvals/components/rule_branches.vue';

describe('Rule Branches', () => {
  let wrapper;

  const defaultProp = {
    rule: {},
  };

  const createComponent = (prop = {}) => {
    wrapper = shallowMount(RuleBranches, {
      propsData: {
        ...defaultProp,
        ...prop,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('displays "Any branch" if there are no protected branches', () => {
    createComponent();
    expect(wrapper.text()).toContain('Any branch');
  });

  it('displays the branch name of the first protected branch', () => {
    const rule = {
      protectedBranches: [
        {
          id: 1,
          name: 'main',
        },
        {
          id: 2,
          name: 'hello',
        },
      ],
    };

    createComponent({
      rule,
    });

    expect(wrapper.text()).toContain('main');
    expect(wrapper.text()).not.toContain('hello');
  });
});
