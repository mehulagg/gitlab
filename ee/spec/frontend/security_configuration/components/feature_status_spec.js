import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import FeatureStatus from 'ee/security_configuration/components/feature_status.vue';
import { generateFeatures } from './helpers';

const gitlabCiHistoryPath = '/ci/history';

describe('FeatureStatus component', () => {
  let wrapper;
  let feature;

  const createComponent = options => {
    wrapper = shallowMount(FeatureStatus, options);
  };

  afterEach(() => {
    wrapper.destroy();
    feature = undefined;
  });

  const findHistoryLink = () => wrapper.find(GlLink);

  describe.each`
    context                       | type      | configured | gitlabCiPresent | shouldShowHistory
    ${'no CI with sast disabled'} | ${'sast'} | ${false}   | ${false}        | ${false}
    ${'CI with sast disabled'}    | ${'sast'} | ${false}   | ${true}         | ${false}
    ${'no CI with sast enabled'}  | ${'sast'} | ${true}    | ${false}        | ${false}
    ${'CI with foo enabled'}      | ${'foo'}  | ${true}    | ${true}         | ${false}
    ${'CI with sast enabled'}     | ${'sast'} | ${true}    | ${true}         | ${true}
  `('given $context', ({ type, configured, gitlabCiPresent, shouldShowHistory }) => {
    beforeEach(() => {
      [feature] = generateFeatures(1, { type, configured });

      createComponent({
        propsData: { feature, gitlabCiPresent, gitlabCiHistoryPath },
      });
    });

    it('shows feature status text', () => {
      expect(wrapper.text()).toContain(feature.status);
    });

    it(`${shouldShowHistory ? 'shows' : 'does not show'} the history link`, () => {
      expect(findHistoryLink().exists()).toBe(shouldShowHistory);
    });

    if (shouldShowHistory) {
      it("sets the link's href correctly", () => {
        expect(findHistoryLink().attributes('href')).toBe(gitlabCiHistoryPath);
      });
    }
  });
});
