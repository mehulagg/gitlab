import { shallowMount } from '@vue/test-utils';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import PipelineArtifacts from '~/pipelines/components/pipelines_list/pipelines_artifacts.vue';

describe('Pipelines Artifacts dropdown', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(PipelineArtifacts, {
      propsData: {
        artifacts: [
          {
            name: 'artifact',
            path: '/download/path',
          },
          {
            name: 'artifact two',
            path: '/download/path-two',
          },
        ],
      },
    });
  };

  const findGlDropdownItem = () => wrapper.find(GlDropdownItem);
  const findAllGlDropdownItems = () => wrapper.find(GlDropdown).findAll(GlDropdownItem);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should render a dropdown with all the provided artifacts', () => {
    expect(findAllGlDropdownItems()).toHaveLength(2);
  });

  it('should render a link with the provided path', () => {
    expect(findGlDropdownItem().attributes('href')).toEqual('/download/path');

    expect(findGlDropdownItem().text()).toContain('artifact');
  });
});
