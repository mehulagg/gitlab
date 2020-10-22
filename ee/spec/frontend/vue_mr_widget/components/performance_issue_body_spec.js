import { shallowMount } from '@vue/test-utils';
import component from 'ee/vue_merge_request_widget/components/performance_issue_body.vue';

describe('performance issue body', () => {
  let wrapper;

  const performanceIssue = {
    delta: 0.1999999999998181,
    name: 'Transfer Size (KB)',
    path: '/',
    score: 4974.8,
  };

  beforeEach(() => {
    wrapper = shallowMount(component, {
      propsData: {
        issue: performanceIssue,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders issue name', () => {
    expect(wrapper.text()).toContain(performanceIssue.name);
  });

  it('renders issue score formatted', () => {
    expect(wrapper.text()).toContain('4974.80');
  });

  it('renders issue delta formatted', () => {
    expect(wrapper.text()).toContain('(+0.19)');
  });
});
