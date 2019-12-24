import { shallowMount, createLocalVue } from '@vue/test-utils';
import ProjectHeader from 'ee/operations/components/dashboard/project_header.vue';
import { trimText } from 'helpers/text_helper';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { mockOneProject } from '../../mock_data';

const localVue = createLocalVue();

describe('project header component', () => {
  let wrapper;

  const factory = () => {
    wrapper = shallowMount(localVue.extend(ProjectHeader), {
      propsData: {
        project: mockOneProject,
      },
      localVue,
      sync: false,
      attachToDocument: true,
    });
  };

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders project name with namespace', () => {
    const namespace = wrapper.find('.js-project-namespace').text();
    const name = wrapper.find('.js-project-name').text();

    expect(trimText(namespace).trim()).toBe(`${mockOneProject.namespace.name} /`);
    expect(trimText(name).trim()).toBe(mockOneProject.name);
  });

  it('links project name to project', () => {
    const path = mockOneProject.web_url;

    expect(wrapper.find('.js-project-link').attributes('href')).toBe(path);
  });

  describe('remove button', () => {
    it('renders removal button icon', () => {
      expect(wrapper.contains('.js-remove-button')).toBe(true);
    });

    it('renders correct title for removal icon', () => {
      const button = wrapper.find('.js-remove-button');

      expect(button.attributes('title')).toBe('Remove card');
    });

    it('emits project removal link on click', () => {
      wrapper.find('.js-remove-button').vm.$emit('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emittedByOrder()).toContainEqual(
          expect.objectContaining({
            name: 'remove',
            args: [mockOneProject.remove_path],
          }),
        );
      });
    });
  });

  describe('wrapped components', () => {
    describe('project avatar', () => {
      it('renders', () => {
        expect(wrapper.findAll(ProjectAvatar).length).toBe(1);
      });

      it('binds project', () => {
        expect(wrapper.find(ProjectAvatar).props('project')).toEqual(mockOneProject);
      });
    });
  });
});
