/* eslint-disable @gitlab/require-i18n-strings */
import { createTwoFilesPatch } from 'diff';
import { commitActionTypes } from '~/ide/constants';

const DEV_NULL = '/dev/null';
const DEFAULT_MODE = '100644';
const NO_NEW_LINE = '\\ No newline at end of file';
const NEW_LINE = '\n';

/**
 * Cleans patch generated by `diff` package.
 *
 * - Removes "=======" separator added at the beginning
 */
const cleanTwoFilesPatch = (text) => text.replace(/^(=+\s*)/, '');

const endsWithNewLine = (val) => !val || val[val.length - 1] === NEW_LINE;

const addEndingNewLine = (val) => (endsWithNewLine(val) ? val : val + NEW_LINE);

const removeEndingNewLine = (val) => (endsWithNewLine(val) ? val.substr(0, val.length - 1) : val);

const diffHead = (prevPath, newPath = '') =>
  `diff --git "a/${prevPath}" "b/${newPath || prevPath}"`;

const createDiffBody = (path, content, isCreate) => {
  if (!content) {
    return '';
  }

  const prefix = isCreate ? '+' : '-';
  const fromPath = isCreate ? DEV_NULL : `a/${path}`;
  const toPath = isCreate ? `b/${path}` : DEV_NULL;

  const hasNewLine = endsWithNewLine(content);
  const lines = removeEndingNewLine(content).split(NEW_LINE);

  const chunkHead = isCreate ? `@@ -0,0 +1,${lines.length} @@` : `@@ -1,${lines.length} +0,0 @@`;
  const chunk = lines
    .map((line) => `${prefix}${line}`)
    .concat(!hasNewLine ? [NO_NEW_LINE] : [])
    .join(NEW_LINE);

  return `--- ${fromPath}
+++ ${toPath}
${chunkHead}
${chunk}`;
};

const createMoveFileDiff = (prevPath, newPath) => `${diffHead(prevPath, newPath)}
rename from ${prevPath}
rename to ${newPath}`;

const createNewFileDiff = (path, content) => {
  const diff = createDiffBody(path, content, true);

  return `${diffHead(path)}
new file mode ${DEFAULT_MODE}
${diff}`;
};

const createDeleteFileDiff = (path, content) => {
  const diff = createDiffBody(path, content, false);

  return `${diffHead(path)}
deleted file mode ${DEFAULT_MODE}
${diff}`;
};

const createUpdateFileDiff = (path, oldContent, newContent) => {
  const patch = createTwoFilesPatch(`a/${path}`, `b/${path}`, oldContent, newContent);

  return `${diffHead(path)}
${cleanTwoFilesPatch(patch)}`;
};

const createFileDiffRaw = (file, action) => {
  switch (action) {
    case commitActionTypes.move:
      return createMoveFileDiff(file.prevPath, file.path);
    case commitActionTypes.create:
      return createNewFileDiff(file.path, file.content);
    case commitActionTypes.delete:
      return createDeleteFileDiff(file.path, file.content);
    case commitActionTypes.update:
      return createUpdateFileDiff(file.path, file.raw || '', file.content);
    default:
      return '';
  }
};

/**
 * Create a git diff for a single IDE file.
 *
 * ## Notes:
 * When called with `commitActionType.move`, it assumes that the move
 * is a 100% similarity move. No diff will be generated. This is because
 * generating a move with changes is not support by the current IDE, since
 * the source file might not have it's content loaded yet.
 *
 * When called with `commitActionType.delete`, it does not support
 * deleting files with a mode different than 100644. For the IDE mirror, this
 * isn't needed because deleting is handled outside the unified patch.
 *
 * ## References:
 * - https://git-scm.com/docs/git-diff#_generating_patches_with_p
 */
const createFileDiff = (file, action) =>
  // It's important that the file diff ends in a new line - git expects this.
  addEndingNewLine(createFileDiffRaw(file, action));

export default createFileDiff;
