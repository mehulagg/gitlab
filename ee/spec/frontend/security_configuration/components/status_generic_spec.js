import { shallowMount } from '@vue/test-utils';
import StatusGeneric from 'ee/security_configuration/components/status_generic.vue';
import { generateFeatures } from './helpers';

describe('StatusGeneric component', () => {
  let wrapper;

  const createComponent = (options) => {
    wrapper = shallowMount(StatusGeneric, options);
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe.each`
    context                                         | configured | autoDevopsEnabled | status
    ${'not configured'}                             | ${false}   | ${false}          | ${StatusGeneric.i18n.notEnabled}
    ${'not configured, but Auto DevOps is enabled'} | ${false}   | ${true}           | ${StatusGeneric.i18n.notEnabled}
    ${'configured'}                                 | ${true}    | ${false}          | ${StatusGeneric.i18n.enabled}
    ${'configured with Auto DevOps'}                | ${true}    | ${true}           | ${StatusGeneric.i18n.enabledWithAutoDevOps}
  `('given the feature is $context', ({ configured, autoDevopsEnabled, status }) => {
    let feature;

    beforeEach(() => {
      [feature] = generateFeatures(1, { configured });

      createComponent({
        propsData: { feature, autoDevopsEnabled },
      });
    });

    it(`shows the status "${status}"`, () => {
      expect(wrapper.text()).toBe(status);
    });
  });
});
