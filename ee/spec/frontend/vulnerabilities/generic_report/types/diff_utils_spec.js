import { diffChars } from 'diff';
import { LINE_TYPES } from 'ee/vulnerabilities/components/generic_report/types/constants';
import {
  groupActionsByLines,
  createDiffData,
} from 'ee/vulnerabilities/components/generic_report/types/diff_utils';

function actionType(action) {
  let type;
  if (action.removed === undefined && action.added === undefined) {
    type = LINE_TYPES.NORMAL;
  } else if (action.removed) {
    type = LINE_TYPES.REMOVED;
  } else if (action.added) {
    type = LINE_TYPES.ADDED;
  }
  return [type, action.value];
}

function checkLineActions(line, actionSpecs) {
  const lineActions = line.actions.map((action) => actionType(action));
  expect(lineActions).toEqual(actionSpecs);
  expect(line.actions).toHaveLength(actionSpecs.length);
}

function checkLine(line, oldLine, newLine, lineType, actionSpecs) {
  expect(line.type).toEqual(lineType);
  expect(line.oldLine).toEqual(oldLine);
  expect(line.newLine).toEqual(newLine);
  checkLineActions(line, actionSpecs);
}

describe('Report Items Diff Utils', () => {
  describe('groupActionsByLines', () => {
    it('correctly groups single-line changes by lines', () => {
      const before = 'hello world';
      const after = 'HELLO world';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines).toHaveLength(1);
      checkLineActions(lines[0], [
        [LINE_TYPES.REMOVED, 'hello'],
        [LINE_TYPES.ADDED, 'HELLO'],
        [LINE_TYPES.NORMAL, ' world'],
      ]);
    });

    it('correctly groups whole-line deletions by lines', () => {
      const before = 'a\nb';
      const after = 'b';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines).toHaveLength(2);

      checkLineActions(lines[0], [[LINE_TYPES.REMOVED, 'a']]);
      checkLineActions(lines[1], [[LINE_TYPES.NORMAL, 'b']]);
    });

    it('correctly groups whole-line insertions by lines', () => {
      const before = 'x\ny\nz';
      const after = 'x\ny\ny\nz';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines).toHaveLength(3);

      checkLineActions(lines[0], [[LINE_TYPES.NORMAL, 'x']]);
      checkLineActions(lines[1], [[LINE_TYPES.NORMAL, 'y']]);
      checkLineActions(lines[2], [
        [LINE_TYPES.ADDED, 'y\n'],
        [LINE_TYPES.NORMAL, 'z'],
      ]);
    });

    it('correctly groups empty line deletions', () => {
      const before = '\n\n';
      const after = '\n';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines).toHaveLength(2);

      checkLineActions(lines[0], [[LINE_TYPES.NORMAL, '']]);
      checkLineActions(lines[1], [[LINE_TYPES.REMOVED, '']]);
    });

    it('Correctly groups empty line additions', () => {
      const before = '\n';
      const after = '\n\n\n';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines).toHaveLength(2);

      checkLineActions(lines[0], [[LINE_TYPES.NORMAL, '']]);
      checkLineActions(lines[1], [[LINE_TYPES.ADDED, '\n\n']]);
    });
  });

  describe('createDiffData', () => {
    it('correctly creates diff lines for single line changes', () => {
      const before = 'hello world';
      const after = 'HELLO world';

      const lines = createDiffData(before, after);
      expect(lines).toHaveLength(2);
      expect(lines[0].type).toEqual(LINE_TYPES.REMOVED);
      checkLine(lines[0], 1, undefined, LINE_TYPES.REMOVED, [
        [LINE_TYPES.REMOVED, 'hello'],
        [LINE_TYPES.NORMAL, ' world'],
      ]);
      checkLine(lines[1], undefined, 1, LINE_TYPES.ADDED, [
        [LINE_TYPES.ADDED, 'HELLO'],
        [LINE_TYPES.NORMAL, ' world'],
      ]);
    });

    it('correctly creates diff lines for single line deletions', () => {
      const before = 'a\nb';
      const after = 'b';

      const lines = createDiffData(before, after);
      expect(lines).toHaveLength(2);
      checkLine(lines[0], 1, undefined, LINE_TYPES.REMOVED, [[LINE_TYPES.REMOVED, 'a']]);
      checkLine(lines[1], 2, 1, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, 'b']]);
    });

    it('correctly tracks line numbers for single-line additions', () => {
      const before = 'x\ny\nz';
      const after = 'x\ny\ny\nz';

      const lines = createDiffData(before, after);
      expect(lines).toHaveLength(4);

      checkLine(lines[0], 1, 1, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, 'x']]);
      checkLine(lines[1], 2, 2, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, 'y']]);
      checkLine(lines[2], undefined, 3, LINE_TYPES.ADDED, [[LINE_TYPES.ADDED, 'y']]);
      checkLine(lines[3], 3, 4, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, 'z']]);
    });

    it('correctly tracks line numbers for multi-line additions', () => {
      const before = 'Hello there\nHello world\nhello again';
      const after = 'Hello there\nHello World\nanew line\nhello again\nhello again';

      const lines = createDiffData(before, after);
      expect(lines).toHaveLength(6);

      checkLine(lines[0], 1, 1, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, 'Hello there']]);
      checkLine(lines[1], 2, undefined, LINE_TYPES.REMOVED, [
        [LINE_TYPES.NORMAL, 'Hello '],
        [LINE_TYPES.REMOVED, 'w'],
        [LINE_TYPES.NORMAL, 'orld'],
      ]);
      checkLine(lines[2], undefined, 2, LINE_TYPES.ADDED, [
        [LINE_TYPES.NORMAL, 'Hello '],
        [LINE_TYPES.ADDED, 'W'],
        [LINE_TYPES.NORMAL, 'orld'],
      ]);
      checkLine(lines[3], undefined, 3, LINE_TYPES.ADDED, [[LINE_TYPES.ADDED, 'anew line']]);
      checkLine(lines[4], 3, 4, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, 'hello again']]);
      checkLine(lines[5], undefined, 5, LINE_TYPES.ADDED, [[LINE_TYPES.ADDED, 'hello again']]);
    });

    it('correctly diffs empty line deletions', () => {
      const before = '\n\n';
      const after = '\n';

      const lines = createDiffData(before, after);
      expect(lines).toHaveLength(2);

      checkLine(lines[0], 1, 1, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, '']]);
      checkLine(lines[1], 2, undefined, LINE_TYPES.REMOVED, [[LINE_TYPES.REMOVED, '']]);
    });

    it('correctly diffs empty line additions', () => {
      const before = '\n';
      const after = '\n\n\n';

      const lines = createDiffData(before, after);
      expect(lines).toHaveLength(3);

      checkLine(lines[0], 1, 1, LINE_TYPES.NORMAL, [[LINE_TYPES.NORMAL, '']]);
      checkLine(lines[1], undefined, 2, LINE_TYPES.ADDED, [[LINE_TYPES.ADDED, '']]);
      checkLine(lines[2], undefined, 3, LINE_TYPES.ADDED, [[LINE_TYPES.ADDED, '']]);
    });
  });
});
