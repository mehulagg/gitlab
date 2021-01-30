import { shallowMount } from '@vue/test-utils';
import { GlDropdown } from '@gitlab/ui';
import RepoDropdown from '~/projects/compare/components/repo_dropdown.vue';

const defaultProps = {
  paramsName: 'to',
};

const projectToId = '1';
const projectToName = 'some-to-name';
const projectFromId = '2';
const projectFromName = 'some-from-name';

const defaultProvide = {
  projectTo: `{"id":${projectToId},"name":"${projectToName}"}`,
  projectsFrom: `[{"id":${projectFromId},"name":"${projectFromName}"}, {"id":3,"name":"some-from-another-name"}]`,
};

describe('RepoDropdown component', () => {
  let wrapper;

  const createComponent = (props = {}, provide = {}) => {
    wrapper = shallowMount(RepoDropdown, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide: {
        ...defaultProvide,
        ...provide,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGlDropdown = () => wrapper.find(GlDropdown);

  describe('Source Revision', () => {
    beforeEach(() => {
      createComponent();
    });

    it('set hidden input', () => {
      expect(wrapper.find('input[type="hidden"]').attributes('value')).toBe(projectToId);
    });

    it('displays the project name in the disabled dropdown', () => {
      expect(findGlDropdown().props('text')).toBe(projectToName);
      expect(findGlDropdown().props('disabled')).toBe(true);
    });
  });

  describe('Target Revision', () => {
    beforeEach(() => {
      createComponent({ paramsName: 'from' });
    });

    it('set hidden input of the first project', () => {
      expect(wrapper.find('input[type="hidden"]').attributes('value')).toBe(projectFromId);
    });

    it('displays the first project name initially in the dropdown', () => {
      expect(findGlDropdown().props('text')).toBe(projectFromName);
    });

    it('updates the hiddin input value when onClick method is triggered', async () => {
      const repoId = '100';
      wrapper.vm.onClick({ id: repoId });
      await wrapper.vm.$nextTick();
      expect(wrapper.find('input[type="hidden"]').attributes('value')).toBe(repoId);
    });
  });
});
