import { GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import PipelineConfigReferenceCard from '~/pipeline_editor/components/drawer/cards/pipeline_config_reference_card.vue';

describe('Pipeline config reference card', () => {
  let wrapper;

  const defaultProvide = {
    ciExamplesHelpPagePath: 'help/ci/examples/',
    ciIntroductionHelpPagePath: 'help/ci/introduction',
    needsHelpPagePath: 'help/ci/yaml#needs',
    ymlHelpPagePath: 'help/ci/yaml',
  };

  const createComponent = () => {
    wrapper = shallowMount(PipelineConfigReferenceCard, {
      provide: {
        ...defaultProvide,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  const findCiExamplesLink = () => wrapper.find('[data-testid="ci-examples-link"]');
  const findCiIntroLink = () => wrapper.find('[data-testid="ci-intro-link"]');
  const findNeedsLink = () => wrapper.find('[data-testid="needs-link"]');
  const findYmlSyntaxLink = () => wrapper.find('[data-testid="yml-syntax-link"]');

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
    expect(wrapper.text()).toContain(wrapper.vm.$options.i18n.firstParagraph);
  });

  it('renders the links', () => {
    expect(findCiExamplesLink().attributes('href')).toBe(defaultProvide.ciExamplesHelpPagePath);
    expect(findCiIntroLink().attributes('href')).toBe(defaultProvide.ciIntroductionHelpPagePath);
    expect(findNeedsLink().attributes('href')).toBe(defaultProvide.needsHelpPagePath);
    expect(findYmlSyntaxLink().attributes('href')).toBe(defaultProvide.ymlHelpPagePath);
  });
});
