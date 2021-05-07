import { shallowMount } from '@vue/test-utils';
import SecurityChartsLayout from 'ee/security_dashboard/components/security_charts_layout.vue';
import SurveyRequestBanner from 'ee/security_dashboard/components/survey_request_banner.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('Security Charts Layout component', () => {
  let wrapper;

  const DummyComponent = {
    name: 'dummy-component-1',
    template: '<p>dummy component 1</p>',
  };

  const findDummyComponent = () => wrapper.findComponent(DummyComponent);
  const findTitle = () => wrapper.findByTestId('title');
  const findSurveyBanner = () => wrapper.findComponent(SurveyRequestBanner);

  const createWrapper = (slots) => {
    wrapper = extendedWrapper(shallowMount(SecurityChartsLayout, { slots }));
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('should render the default slot and survey banner', () => {
    createWrapper({ default: DummyComponent });

    expect(findDummyComponent().exists()).toBe(true);
    expect(findTitle().exists()).toBe(true);
    expect(findSurveyBanner().exists()).toBe(true);
  });

  it('should render the empty-state slot and survey banner', () => {
    createWrapper({ 'empty-state': DummyComponent });

    expect(findDummyComponent().exists()).toBe(true);
    expect(findTitle().exists()).toBe(false);
    expect(findSurveyBanner().exists()).toBe(true);
  });

  it('should render the loading slot', () => {
    createWrapper({ loading: DummyComponent });

    expect(findDummyComponent().exists()).toBe(true);
    expect(findTitle().exists()).toBe(false);
    expect(findSurveyBanner().exists()).toBe(false);
  });
});
