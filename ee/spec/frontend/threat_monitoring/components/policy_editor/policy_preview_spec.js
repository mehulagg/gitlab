import { GlTabs } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';

describe('PolicyPreview component', () => {
  let wrapper;

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(PolicyPreview, {
      propsData: {
        ...propsData,
      },
    });
  };

  beforeEach(() => {
    factory({
      propsData: {
        policyYaml: 'foo',
        policyDescription: '<strong>bar</strong><br><div>test</div><script></script>',
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders policy preview tabs', () => {
    expect(wrapper.find(GlTabs).element).toMatchSnapshot();
  });

  describe('with initialTab', () => {
    beforeEach(() => {
      factory({
        propsData: {
          policyYaml: 'foo',
          policyDescription: 'bar',
          initialTab: 1,
        },
      });
    });

    it('selects initial tab', () => {
      expect(wrapper.find(GlTabs).attributes().value).toEqual('1');
    });
  });
});
