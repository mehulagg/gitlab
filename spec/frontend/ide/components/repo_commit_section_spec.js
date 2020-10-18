import { mount } from '@vue/test-utils';
import { createStore } from '~/ide/stores';
import { createRouter } from '~/ide/ide_router';
import { keepAlive } from '../../helpers/keep_alive_component_helper';
import RepoCommitSection from '~/ide/components/repo_commit_section.vue';
import EmptyState from '~/ide/components/commit_sidebar/empty_state.vue';
import { file } from '../helpers';

const TEST_NO_CHANGES_SVG = 'nochangessvg';

describe('RepoCommitSection', () => {
  let wrapper;
  let router;
  let store;

  function createComponent() {
    wrapper = mount(keepAlive(RepoCommitSection), { store });
  }

  function setupDefaultState() {
    store.state.noChangesStateSvgPath = 'svg';
    store.state.committedStateSvgPath = 'commitsvg';
    store.state.currentProjectId = 'abcproject';
    store.state.currentBranchId = 'master';
    store.state.projects.abcproject = {
      web_url: '',
      branches: {
        master: {
          workingReference: '1',
        },
      },
    };

    const files = [file('file1'), file('file2')].map(f =>
      Object.assign(f, {
        type: 'blob',
        content: 'orginal content',
      }),
    );

    store.state.currentBranch = 'master';
    store.state.changedFiles = [{ ...files[0] }, { ...files[1] }];
    store.state.changedFiles.forEach(f =>
      Object.assign(f, {
        changed: true,
        content: 'testing',
      }),
    );

    files.forEach(f => {
      store.state.entries[f.path] = f;
    });
  }

  beforeEach(() => {
    store = createStore();
    router = createRouter(store);

    jest.spyOn(store, 'dispatch');
    jest.spyOn(router, 'push').mockImplementation();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('empty state', () => {
    beforeEach(() => {
      store.state.noChangesStateSvgPath = TEST_NO_CHANGES_SVG;
      store.state.committedStateSvgPath = 'svg';

      createComponent();
    });

    it('renders no changes text', () => {
      expect(
        wrapper
          .find(EmptyState)
          .text()
          .trim(),
      ).toContain('No changes');
      expect(
        wrapper
          .find(EmptyState)
          .find('img')
          .attributes('src'),
      ).toBe(TEST_NO_CHANGES_SVG);
    });
  });

  describe('default', () => {
    beforeEach(() => {
      setupDefaultState();

      createComponent();
    });

    it('opens last opened file', () => {
      expect(store.state.openFiles.length).toBe(1);
      expect(store.state.openFiles[0].pending).toBe(true);
    });

    it('calls openPendingTab', () => {
      expect(store.dispatch).toHaveBeenCalledWith('openPendingTab', store.getters.lastOpenedFile);
    });

    it('renders a commit section', () => {
      const changedFileNames = wrapper
        .findAll('.multi-file-commit-list > li')
        .wrappers.map(x => x.text().trim());

      expect(changedFileNames).toEqual(store.state.changedFiles.map(x => x.path));
    });

    it('does not show empty state', () => {
      expect(wrapper.find(EmptyState).exists()).toBe(false);
    });
  });

  describe('if nothing is changed', () => {
    beforeEach(() => {
      setupDefaultState();

      store.state.openFiles = [...Object.values(store.state.entries)];
      store.state.openFiles[0].active = true;
      store.state.changedFiles = [];

      createComponent();
    });

    it('opens currently active file', () => {
      expect(store.state.openFiles.length).toBe(1);
      expect(store.state.openFiles[0].pending).toBe(true);

      expect(store.dispatch).toHaveBeenCalledWith(
        'openPendingTab',
        store.state.entries[store.getters.activeFile.path],
      );
    });
  });

  describe('with changed file', () => {
    beforeEach(() => {
      setupDefaultState();

      createComponent();
    });

    it('calls openPendingTab', () => {
      expect(store.dispatch).toHaveBeenCalledWith('openPendingTab', store.getters.lastOpenedFile);
    });

    it('does not show empty state', () => {
      expect(wrapper.find(EmptyState).exists()).toBe(false);
    });
  });

  describe('activated', () => {
    let inititializeSpy;

    beforeEach(async () => {
      createComponent();

      inititializeSpy = jest.spyOn(wrapper.find(RepoCommitSection).vm, 'initialize');
      store.state.viewer = 'diff';

      await wrapper.vm.reactivate();
    });

    it('re initializes the component', () => {
      expect(inititializeSpy).toHaveBeenCalled();
    });
  });
});
