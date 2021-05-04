import { GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import FirstPipelineCard from '~/pipeline_editor/components/drawer/cards/first_pipeline_card.vue';
import PipelineVisualReference from '~/pipeline_editor/components/drawer/ui/pipeline_visual_reference.vue';

describe('First pipeline card', () => {
  let wrapper;

  const defaultProvide = {
    ciExamplesHelpPagePath: '/pipelines/examples',
    runnerHelpPagePath: '/help/runners',
  };

  const createComponent = () => {
    wrapper = shallowMount(FirstPipelineCard, {
      provide: {
        ...defaultProvide,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  const findPipelinesLink = () => wrapper.find('[data-testid="pipelines-link"]');
  const findRunnersLink = () => wrapper.find('[data-testid="runners-link"]');
  const findVisualReference = () => wrapper.findComponent(PipelineVisualReference);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the title', () => {
    expect(wrapper.text()).toContain(wrapper.vm.$options.i18n.title);
  });

  it('renders the content', () => {
    expect(findVisualReference().exists()).toBe(true);
  });

  it('renders the links', () => {
    expect(findPipelinesLink().attributes('href')).toBe(defaultProvide.ciExamplesHelpPagePath);
    expect(findRunnersLink().attributes('href')).toBe(defaultProvide.runnerHelpPagePath);
  });
});
