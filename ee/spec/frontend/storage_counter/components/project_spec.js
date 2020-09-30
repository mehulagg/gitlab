import { shallowMount } from '@vue/test-utils';
import Project from 'ee/storage_counter/components/project.vue';
import StorageRow from 'ee/storage_counter/components/storage_row.vue';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';

let wrapper;
const data = {
  id: '8',
  fullPath: 'h5bp/html5-boilerplate',
  nameWithNamespace: 'H5bp / Html5 Boilerplate',
  avatarUrl: null,
  webUrl: 'http://localhost:3001/h5bp/html5-boilerplate',
  name: 'Html5 Boilerplate',
  statistics: {
    commitCount: 0,
    storageSize: 1293346,
    repositorySize: 0,
    lfsObjectsSize: 0,
    buildArtifactsSize: 1272375,
    packagesSize: 0,
    wikiSize: 2048,
    snippetsSize: 1024,
  },
};

function factory(project) {
  wrapper = shallowMount(Project, {
    propsData: {
      project,
    },
  });
}

const findTableRow = () => wrapper.find('[data-testid="projectTableRow"]');
const findStorageRow = () => wrapper.find(StorageRow);

describe('Storage Counter project component', () => {
  beforeEach(() => {
    factory(data);
  });

  it('renders project avatar', () => {
    expect(wrapper.find(ProjectAvatar).exists()).toBe(true);
  });

  it('renders project name', () => {
    expect(wrapper.text()).toContain(data.nameWithNamespace);
  });

  it('renders formatted storage size', () => {
    expect(wrapper.text()).toContain(numberToHumanSize(data.statistics.storageSize));
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
