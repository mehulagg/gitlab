import Vue from 'vue';
import * as urlUtils from '~/lib/utils/url_utility';
import store from 'ee/ide/stores';
import router from 'ee/ide/ide_router';
import { resetStore, file } from '../helpers';

describe('Multi-file store actions', () => {
  beforeEach(() => {
    spyOn(router, 'push');
  });

  afterEach(() => {
    resetStore(store);
  });

  describe('redirectToUrl', () => {
    it('calls visitUrl', (done) => {
      spyOn(urlUtils, 'visitUrl');

      store.dispatch('redirectToUrl', 'test')
        .then(() => {
          expect(urlUtils.visitUrl).toHaveBeenCalledWith('test');

          done();
        })
        .catch(done.fail);
    });
  });

  describe('setInitialData', () => {
    it('commits initial data', (done) => {
      store.dispatch('setInitialData', { canCommit: true })
        .then(() => {
          expect(store.state.canCommit).toBeTruthy();
          done();
        })
        .catch(done.fail);
    });
  });

  describe('discardAllChanges', () => {
    beforeEach(() => {
      const f = file('discardAll');
      f.changed = true;

      store.state.openFiles.push(f);
      store.state.changedFiles.push(f);
    });

    it('discards changes in file', (done) => {
      store.dispatch('discardAllChanges')
        .then(() => {
          expect(store.state.openFiles.changed).toBeFalsy();
        })
        .then(done)
        .catch(done.fail);
    });

    it('removes all files from changedFiles state', (done) => {
      store.dispatch('discardAllChanges')
        .then(() => {
          expect(store.state.changedFiles.length).toBe(0);
          expect(store.state.openFiles.length).toBe(1);
        })
        .then(done)
        .catch(done.fail);
    });
  });

  describe('closeAllFiles', () => {
    beforeEach(() => {
      store.state.openFiles.push(file('closeAll'));
      store.state.openFiles[0].opened = true;
    });

    it('closes all open files', (done) => {
      store.dispatch('closeAllFiles')
        .then(() => {
          expect(store.state.openFiles.length).toBe(0);

          done();
        })
        .catch(done.fail);
    });
  });

  describe('toggleEditMode', () => {
    it('toggles edit mode', (done) => {
      store.state.editMode = true;

      store.dispatch('toggleEditMode')
        .then(() => {
          expect(store.state.editMode).toBeFalsy();

          done();
        }).catch(done.fail);
    });

    it('sets preview mode', (done) => {
      store.state.currentBlobView = 'repo-editor';
      store.state.editMode = true;

      store.dispatch('toggleEditMode')
        .then(Vue.nextTick)
        .then(() => {
          expect(store.state.currentBlobView).toBe('repo-preview');

          done();
        }).catch(done.fail);
    });
  });

  describe('toggleBlobView', () => {
    it('sets edit mode view if in edit mode', (done) => {
      store.dispatch('toggleBlobView')
        .then(() => {
          expect(store.state.currentBlobView).toBe('repo-editor');

          done();
        })
        .catch(done.fail);
    });

    it('sets preview mode view if not in edit mode', (done) => {
      store.state.editMode = false;

      store.dispatch('toggleBlobView')
      .then(() => {
        expect(store.state.currentBlobView).toBe('repo-preview');

        done();
      })
      .catch(done.fail);
    });
  });

  describe('createTempEntry', () => {
    beforeEach(() => {
      store.state.trees['abcproject/mybranch'] = {
        tree: [],
      };
      store.state.projects.abcproject = {
        web_url: '',
      };
    });

    it('creates a temp tree', (done) => {
      const projectTree = store.state.trees['abcproject/mybranch'];

      store.dispatch('createTempEntry', {
        projectId: 'abcproject',
        branchId: 'mybranch',
        parent: projectTree,
        name: 'test',
        type: 'tree',
      })
      .then(() => {
        const baseTree = projectTree.tree;
        expect(baseTree.length).toBe(1);
        expect(baseTree[0].tempFile).toBeTruthy();
        expect(baseTree[0].type).toBe('tree');

        done();
      })
      .catch(done.fail);
    });

    it('creates temp file', (done) => {
      const projectTree = store.state.trees['abcproject/mybranch'];

      store.dispatch('createTempEntry', {
        projectId: 'abcproject',
        branchId: 'mybranch',
        parent: projectTree,
        name: 'test',
        type: 'blob',
      })
      .then(() => {
        const baseTree = projectTree.tree;
        expect(baseTree.length).toBe(1);
        expect(baseTree[0].tempFile).toBeTruthy();
        expect(baseTree[0].type).toBe('blob');

        done();
      })
      .catch(done.fail);
    });
  });

  describe('popHistoryState', () => {

  });

  describe('scrollToTab', () => {
    it('focuses the current active element', (done) => {
      document.body.innerHTML += '<div id="tabs"><div class="active"><div class="repo-tab"></div></div></div>';
      const el = document.querySelector('.repo-tab');
      spyOn(el, 'focus');

      store.dispatch('scrollToTab')
        .then(() => {
          setTimeout(() => {
            expect(el.focus).toHaveBeenCalled();

            document.getElementById('tabs').remove();

            done();
          });
        })
        .catch(done.fail);
    });
  });

  describe('stageAllChanges', () => {
    it('adds all files from changedFiles to stagedFiles', (done) => {
      const f = file();
      store.state.changedFiles.push(f);
      store.state.changedFiles.push(file('new'));

      store.dispatch('stageAllChanges')
        .then(() => {
          expect(store.state.stagedFiles.length).toBe(2);
          expect(store.state.stagedFiles[0]).toEqual(f);

          done();
        })
        .catch(done.fail);
    });

    it('sets all files from changedFiles as staged after adding to stagedFiles', (done) => {
      store.state.changedFiles.push(file());
      store.state.changedFiles.push(file('new'));

      store.dispatch('stageAllChanges')
        .then(() => {
          expect(store.state.changedFiles.length).toBe(2);
          store.state.changedFiles.forEach((f) => {
            expect(f.staged).toBeTruthy();
          });

          done();
        })
        .catch(done.fail);
    });
  });

  describe('unstageAllChanges', () => {
    let f;

    beforeEach(() => {
      f = {
        ...file(),
        type: 'blob',
        staged: true,
      };

      store.state.changedFiles.push({
        ...f,
      });
    });

    it('sets staged to false in changedFiles when unstaging', (done) => {
      store.state.stagedFiles.push(f);

      store.dispatch('unstageAllChanges')
        .then(() => {
          expect(store.state.stagedFiles.length).toBe(0);
          expect(store.state.changedFiles[0].staged).toBeFalsy();

          done();
        })
        .catch(done.fail);
    });

    it('removes all files from stagedFiles after unstaging', (done) => {
      store.state.stagedFiles.push(file());

      store.dispatch('unstageAllChanges')
        .then(() => {
          expect(store.state.stagedFiles.length).toBe(0);

          done();
        })
        .catch(done.fail);
    });
  });
});
