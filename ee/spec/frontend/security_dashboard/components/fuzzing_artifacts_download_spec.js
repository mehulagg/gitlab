import { GlButton, GlDropdown, GlDeprecatedDropdownItem } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import FuzzingArtifactsDownload from 'ee/security_dashboard/components/fuzzing_artifacts_download.vue';
import createStore from 'ee/security_dashboard/store';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Filter component', () => {
  const projectId = 1;
  const jobs = [{ ref: 'master', name: 'fuzz' }, { ref: 'master', name: 'fuzz 2' }];

  let wrapper;
  let store;

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(FuzzingArtifactsDownload, {
      localVue,
      store,
      propsData: {
        projectId,
        ...props,
      },
    });
  };

  beforeEach(() => {
    store = createStore();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('with one fuzzing job with artifacts', () => {
    beforeEach(() => {
      createWrapper({ jobs: [jobs[0]] });
    });

    it('should render a download button', () => {
      expect(wrapper.find(GlButton).exists()).toBe(true);
      expect(wrapper.find(GlDropdown).exists()).toBe(false);
    });

    it('should render with href set to the correct filepath', () => {
      const href = `/api/v4/projects/${projectId}/jobs/artifacts/${
        jobs[0].ref
      }/download?job=${encodeURIComponent(jobs[0].name)}`;
      expect(wrapper.find(GlButton).attributes('href')).toBe(href);
    });
  });

  describe('with several fuzzing jobs with artifacts', () => {
    beforeEach(() => {
      createWrapper({ jobs });
    });

    it('should render a dropdown button with several items', () => {
      expect(wrapper.find(GlButton).exists()).toBe(false);
      expect(wrapper.find(GlDropdown).exists()).toBe(true);
      expect(wrapper.findAll(GlDeprecatedDropdownItem).length).toBe(2);
    });

    it('should render with href set to the correct filepath for every element', () => {
      const wrapperArray = wrapper.findAll(GlDeprecatedDropdownItem);
      wrapperArray.wrappers.forEach((_, index) => {
        const href = `/api/v4/projects/${projectId}/jobs/artifacts/${
          jobs[index].ref
        }/download?job=${encodeURIComponent(jobs[index].name)}`;
        expect(wrapperArray.at(index).attributes().href).toBe(href);
      });
    });
  });
});
