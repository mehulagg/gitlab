import { GlBanner, GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import SurveyRequestBanner from 'ee/security_dashboard/components/shared/survey_request_banner.vue';
import {
  SURVEY_BANNER_LOCAL_STORAGE_KEY,
  SURVEY_BANNER_CURRENT_ID,
} from 'ee/security_dashboard/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import toast from '~/vue_shared/plugins/global_toast';

jest.mock('~/vue_shared/plugins/global_toast');

describe('Survey Request Banner component', () => {
  let wrapper;

  const surveyRequestSvgPath = 'icon.svg';

  const findGlBanner = () => wrapper.findComponent(GlBanner);
  const findAskLaterButton = () => wrapper.findByTestId('ask-later-button');

  const getOffsetDateString = (days) => {
    const date = new Date();
    date.setDate(date.getDate() + days);
    return date.toISOString();
  };

  const createWrapper = () => {
    wrapper = extendedWrapper(
      shallowMount(SurveyRequestBanner, {
        provide: { surveyRequestSvgPath },
        stubs: { GlBanner, GlButton, LocalStorageSync },
      }),
    );
  };

  beforeEach(() => {
    gon.features = {};
  });

  afterEach(() => {
    wrapper.destroy();
    localStorage.removeItem(SURVEY_BANNER_LOCAL_STORAGE_KEY);
  });

  describe('feature flag disabled', () => {
    it('should not show banner regardless of localStorage value', () => {
      [
        getOffsetDateString(1),
        getOffsetDateString(-1),
        SURVEY_BANNER_CURRENT_ID,
        'SOME OTHER ID',
      ].forEach((localStorageValue) => {
        localStorage.setItem(SURVEY_BANNER_LOCAL_STORAGE_KEY, localStorageValue);
        createWrapper();

        expect(findGlBanner().exists()).toBe(false);
      });
    });
  });

  describe('feature flag enabled', () => {
    beforeEach(() => {
      gon.features.vulnerabilityManagementSurvey = true;
    });

    it('shows the banner with the correct components and props', () => {
      createWrapper();
      const { title, buttonText, description } = wrapper.vm.$options.i18n;

      expect(findGlBanner().html()).toContain(description);
      expect(findAskLaterButton().exists()).toBe(true);
      expect(findGlBanner().props()).toMatchObject({
        title,
        buttonText,
        svgPath: surveyRequestSvgPath,
      });
    });

    it.each`
      showOrHide | phrase                     | localStorageValue           | isShown
      ${'hides'} | ${'a future date'}         | ${getOffsetDateString(1)}   | ${false}
      ${'shows'} | ${'a past date'}           | ${getOffsetDateString(-1)}  | ${true}
      ${'hides'} | ${'the current survey ID'} | ${SURVEY_BANNER_CURRENT_ID} | ${false}
      ${'shows'} | ${'a different survey ID'} | ${'SOME OTHER ID'}          | ${true}
    `(
      '$showOrHide the banner if the localStorage value is $phrase',
      async ({ localStorageValue, isShown }) => {
        localStorage.setItem(SURVEY_BANNER_LOCAL_STORAGE_KEY, localStorageValue);
        createWrapper();
        await wrapper.vm.$nextTick();

        expect(findGlBanner().exists()).toBe(isShown);
      },
    );
  });

  describe('closing the banner', () => {
    beforeEach(() => {
      gon.features.vulnerabilityManagementSurvey = true;
    });

    it('hides the banner and will set it to reshow later if the "Ask again later" button is clicked', async () => {
      createWrapper();
      expect(findGlBanner().exists()).toBe(true);

      findAskLaterButton().vm.$emit('click');
      await wrapper.vm.$nextTick();
      const date = new Date(localStorage.getItem(SURVEY_BANNER_LOCAL_STORAGE_KEY));

      expect(findGlBanner().exists()).toBe(false);
      expect(toast).toHaveBeenCalledTimes(1);
      expect(date > new Date()).toBe(true);
    });

    it('hides the banner and sets it to never show again if the close button is clicked', async () => {
      createWrapper();
      expect(findGlBanner().exists()).toBe(true);

      findGlBanner().vm.$emit('close');
      await wrapper.vm.$nextTick();

      expect(findGlBanner().exists()).toBe(false);
      expect(localStorage.getItem(SURVEY_BANNER_LOCAL_STORAGE_KEY)).toBe(SURVEY_BANNER_CURRENT_ID);
    });
  });
});
