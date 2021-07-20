import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import StatusGeneric from 'ee/security_configuration/components/status_generic.vue';
import StatusViewHistory from 'ee/security_configuration/components/status_view_history.vue';
import { REPORT_TYPE_SAST } from '~/vue_shared/security_reports/constants';
import { generateFeatures } from './helpers';

const gitlabCiHistoryPath = '/ci/history';
const autoDevopsEnabled = true;

describe('StatusSast component', () => {
  let wrapper;

  const createComponent = (options) => {
    wrapper = shallowMount(StatusViewHistory, options);
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findHistoryLink = () => wrapper.find(GlLink);

  describe.each`
    context                       | configured | gitlabCiPresent | shouldShowHistory
    ${'no CI with sast disabled'} | ${false}   | ${false}        | ${false}
    ${'CI with sast disabled'}    | ${false}   | ${true}         | ${false}
    ${'no CI with sast enabled'}  | ${true}    | ${false}        | ${false}
    ${'CI with sast enabled'}     | ${true}    | ${true}         | ${true}
  `('given $context', ({ configured, gitlabCiPresent, shouldShowHistory }) => {
    let feature;

    beforeEach(() => {
      [feature] = generateFeatures(1, { type: REPORT_TYPE_SAST, configured });

      createComponent({
        propsData: { feature, gitlabCiPresent, gitlabCiHistoryPath, autoDevopsEnabled },
      });
    });

    it('shows the generic status', () => {
      const genericComponent = wrapper.findComponent(StatusGeneric);
      expect(genericComponent.exists()).toBe(true);
      expect(genericComponent.props()).toEqual({
        feature,
        autoDevopsEnabled,
      });
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
