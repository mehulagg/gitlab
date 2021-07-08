import { shallowMount } from '@vue/test-utils';
import Project from 'ee/other_storage_counter/components/project.vue';
import StorageRow from 'ee/other_storage_counter/components/storage_row.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import ProjectAvatar from '~/vue_shared/components/deprecated_project_avatar/default.vue';
import { projects } from '../mock_data';

let wrapper;
const createComponent = () => {
  wrapper = shallowMount(Project, {
    propsData: {
      project: projects[1],
    },
  });
};

const findTableRow = () => wrapper.find('[data-testid="projectTableRow"]');
const findStorageRow = () => wrapper.find(StorageRow);

describe('Storage Counter project component', () => {
  beforeEach(() => {
    createComponent();
  });

  it('renders project avatar', () => {
    expect(wrapper.find(ProjectAvatar).exists()).toBe(true);
  });

  it('renders project name', () => {
    expect(wrapper.text()).toContain(projects[1].nameWithNamespace);
  });

  it('renders formatted storage size', () => {
    expect(wrapper.text()).toContain(numberToHumanSize(projects[1].statistics.storageSize));
  });

  describe('toggle row', () => {
    describe('on click', () => {
      it('toggles isOpen', () => {
        expect(findStorageRow().exists()).toBe(false);

        findTableRow().trigger('click');

        wrapper.vm.$nextTick(() => {
          expect(findStorageRow().exists()).toBe(true);
          findTableRow().trigger('click');

          wrapper.vm.$nextTick(() => {
            expect(findStorageRow().exists()).toBe(false);
          });
        });
      });
    });
  });
});
