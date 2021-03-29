import { shallowMount } from '@vue/test-utils';
import Project from 'ee/other_storage_counter/components/project.vue';
import ProjectWithExcessStorage from 'ee/other_storage_counter/components/project_with_excess_storage.vue';
import ProjectsTable from 'ee/other_storage_counter/components/projects_table.vue';
import { projects } from '../mock_data';

let wrapper;

const createComponent = ({ additionalRepoStorageByNamespace = false } = {}) => {
  const stubs = {
    'anonymous-stub': additionalRepoStorageByNamespace ? ProjectWithExcessStorage : Project,
  };

  wrapper = shallowMount(ProjectsTable, {
    propsData: {
      projects,
      additionalPurchasedStorageSize: 0,
    },
    stubs,
    provide: {
      glFeatures: {
        additionalRepoStorageByNamespace,
      },
    },
  });
};

const findTableRows = () => wrapper.findAll(Project);
const findTableRowsWithExcessStorage = () => wrapper.findAll(ProjectWithExcessStorage);

describe('Usage Quotas project table component', () => {
  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders regular project rows by default', () => {
    expect(findTableRows()).toHaveLength(3);
    expect(findTableRowsWithExcessStorage()).toHaveLength(0);
  });

  describe('with additional repo storage feature flag ', () => {
    beforeEach(() => {
      createComponent({ additionalRepoStorageByNamespace: true });
    });

    it('renders table row with excess storage', () => {
      expect(findTableRowsWithExcessStorage()).toHaveLength(3);
    });

    it('renders excess storage rows with error state', () => {
      const rowsWithError = findTableRowsWithExcessStorage().filter((r) =>
        r.classes('gl-bg-red-50'),
      );
      expect(rowsWithError).toHaveLength(1);
    });
  });
});
