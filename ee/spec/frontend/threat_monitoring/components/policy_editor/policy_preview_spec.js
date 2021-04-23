import { GlAlert, GlTabs } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';

describe('PolicyPreview component', () => {
  let wrapper;

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findTabs = () => wrapper.findComponent(GlTabs);

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(PolicyPreview, {
      propsData: {
        ...propsData,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with policy description', () => {
    beforeEach(() => {
      factory({
        propsData: {
          policyYaml: 'foo',
          policyDescription: '<strong>bar</strong><br><div>test</div><script></script>',
        },
      });
    });

    it('renders policy preview tabs', () => {
      expect(findTabs().element).toMatchSnapshot();
    });

    it('renders the first tab', () => {
      expect(findTabs().attributes().value).toEqual('0');
    });

    it('does not render the unsupported attributes alert', () => {
      expect(findAlert().exists()).toBe(false);
    });

    describe('initial tab', () => {
      it('selects initial tab', () => {
        factory({
          propsData: {
            policyYaml: 'foo',
            policyDescription: 'bar',
            initialTab: 1,
          },
        });
        expect(findTabs().attributes().value).toEqual('1');
      });
    });
  });

  describe('without policy description', () => {
    beforeEach(() => {
      factory({
        propsData: {
          policyYaml: 'foo',
        },
      });
    });

    it('does render the unsupported attributes alert', () => {
      expect(findAlert().exists()).toBe(true);
    });
  });
});
