import * as types from '../mutation_types';
import { sortTree } from '../utils';
import { diffModes } from '../../constants';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export default {
  [types.SET_FILE_ACTIVE](state, { path, active }) {
    Object.assign(state.entries[path], {
      active,
      lastOpenedAt: new Date().getTime(),
    });

    if (active && !state.entries[path].pending) {
      Object.assign(state, {
        openFiles: state.openFiles.map(f =>
          Object.assign(f, { active: f.pending ? false : f.active }),
        ),
      });
    }
  },
  [types.TOGGLE_FILE_OPEN](state, path) {
    const entry = state.entries[path];

    entry.opened = !entry.opened;
    if (entry.opened && !entry.tempFile) {
      entry.loading = true;
    }

    if (entry.opened) {
      Object.assign(state, {
        openFiles: state.openFiles.filter(f => f.path !== path).concat(state.entries[path]),
      });
    } else {
      Object.assign(state, {
        openFiles: state.openFiles.filter(f => f.key !== entry.key),
      });
    }
  },
  [types.SET_FILE_DATA](state, { data, file }) {
    const stateEntry = state.entries[file.path];
    const openFile = state.openFiles.find(f => f.path === file.path);
    const changedFile = state.changedFiles.find(f => f.path === file.path);

    [stateEntry, openFile, changedFile].forEach(f => {
      if (f) {
        Object.assign(
          f,
          convertObjectPropsToCamelCase(data, { dropKeys: ['path', 'name', 'raw', 'baseRaw'] }),
          {
            raw: (stateEntry && stateEntry.raw) || null,
            baseRaw: null,
          },
        );
      }
    });
  },
  [types.SET_FILE_RAW_DATA](state, { file, raw }) {
    const openPendingFile = state.openFiles.find(
      f => f.path === file.path && f.pending && !(f.tempFile && !f.prevPath),
    );

    if (file.tempFile && file.content === '') {
      Object.assign(state.entries[file.path], { content: raw });
    } else {
      Object.assign(state.entries[file.path], { raw });
    }

    if (!openPendingFile) return;

    if (!openPendingFile.tempFile) {
      openPendingFile.raw = raw;
    } else if (openPendingFile.tempFile) {
      openPendingFile.content = raw;
    }
  },
  [types.SET_FILE_BASE_RAW_DATA](state, { file, baseRaw }) {
    Object.assign(state.entries[file.path], {
      baseRaw,
    });
  },
  [types.UPDATE_FILE_CONTENT](state, { path, content }) {
    const rawContent = state.entries[path].raw;
    const changed = content !== rawContent;

    Object.assign(state.entries[path], {
      content,
      changed,
    });
  },
  [types.SET_FILE_LANGUAGE](state, { file, fileLanguage }) {
    Object.assign(state.entries[file.path], {
      fileLanguage,
    });
  },
  [types.SET_FILE_POSITION](state, { file, editorRow, editorColumn }) {
    Object.assign(state.entries[file.path], {
      editorRow,
      editorColumn,
    });
  },
  [types.SET_FILE_MERGE_REQUEST_CHANGE](state, { file, mrChange }) {
    let diffMode = diffModes.replaced;
    if (mrChange.new_file) {
      diffMode = diffModes.new;
    } else if (mrChange.deleted_file) {
      diffMode = diffModes.deleted;
    } else if (mrChange.renamed_file) {
      diffMode = diffModes.renamed;
    }
    Object.assign(state.entries[file.path], {
      mrChange: {
        ...mrChange,
        diffMode,
      },
    });
  },
  [types.SET_FILE_VIEWMODE](state, { file, viewMode }) {
    Object.assign(state.entries[file.path], {
      viewMode,
    });
  },
  [types.DISCARD_FILE_CHANGES](state, path) {
    const entry = state.entries[path];
    const { deleted } = entry;

    Object.assign(state.entries[path], {
      content: state.entries[path].raw,
      changed: false,
      deleted: false,
    });

    if (deleted) {
      const parent = entry.parentPath
        ? state.entries[entry.parentPath]
        : state.trees[`${state.currentProjectId}/${state.currentBranchId}`];

      parent.tree = sortTree(parent.tree.concat(entry));
    }
  },
  [types.ADD_FILE_TO_CHANGED](state, path) {
    Object.assign(state, {
      changedFiles: state.changedFiles.concat(state.entries[path]),
    });
  },
  [types.REMOVE_FILE_FROM_CHANGED](state, path) {
    Object.assign(state, {
      changedFiles: state.changedFiles.filter(f => f.path !== path),
    });
  },
  [types.TOGGLE_FILE_CHANGED](state, { file, changed }) {
    Object.assign(state.entries[file.path], {
      changed,
    });
  },
  [types.ADD_PENDING_TAB](state, file) {
    state.entries[file.path].opened = false;
    state.entries[file.path].active = false;
    state.entries[file.path].lastOpenedAt = new Date().getTime();
    state.openFiles.forEach(f =>
      Object.assign(f, {
        opened: false,
        active: false,
      }),
    );
    state.openFiles = [
      {
        ...file,
        pending: true,
        opened: true,
        active: true,
      },
    ];
  },
  [types.REMOVE_PENDING_TAB](state, file) {
    Object.assign(state, {
      openFiles: state.openFiles.filter(f => f.key !== file.key),
    });
  },
};
