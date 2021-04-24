import { diffChars } from 'diff';
import {
  groupActionsByLines,
  createDiffData,
} from 'ee/vulnerabilities/components/generic_report/types/diff.vue';

function actionType(action) {
  let type;
  if (action.removed === undefined && action.added === undefined) {
    type = 'normal';
  } else if (action.removed) {
    type = 'removed';
  } else if (action.added) {
    type = 'added';
  }
  return [type, action.value];
}

function checkLineActions(line, actionSpecs) {
  const lineActions = line.actions.map((action) => actionType(action));
  expect(lineActions).toEqual(actionSpecs);
  expect(line.actions.length).toEqual(actionSpecs.length);
}

function checkLine(line, oldLine, newLine, lineType, actionSpecs) {
  expect(line.type).toEqual(lineType);
  expect(line.old_line).toEqual(oldLine);
  expect(line.new_line).toEqual(newLine);
  checkLineActions(line, actionSpecs);
}

describe('Report Items Diff Utils', () => {
  describe('groupActionsByLines', () => {
    it('Correctly groups single-line changes by lines', () => {
      const before = 'hello world';
      const after = 'HELLO world';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines.length).toEqual(1);
      checkLineActions(lines[0], [
        ['removed', 'hello'],
        ['added', 'HELLO'],
        ['normal', ' world'],
      ]);
    });

    it('Correctly groups whole-line deletions by lines', () => {
      const before = 'a\nb';
      const after = 'b';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines.length).toEqual(2);

      checkLineActions(lines[0], [['removed', 'a']]);
      checkLineActions(lines[1], [['normal', 'b']]);
    });

    it('Correctly groups whole-line insertions by lines', () => {
      const before = 'x\ny\nz';
      const after = 'x\ny\ny\nz';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines.length).toEqual(3);

      checkLineActions(lines[0], [['normal', 'x']]);
      checkLineActions(lines[1], [['normal', 'y']]);
      checkLineActions(lines[2], [
        ['added', 'y\n'],
        ['normal', 'z'],
      ]);
    });

    it('Correctly groups empty line deletions', () => {
      const before = '\n\n';
      const after = '\n';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines.length).toEqual(2);

      checkLineActions(lines[0], [['normal', '']]);
      checkLineActions(lines[1], [['removed', '']]);
    });

    it('Correctly groups empty line additions', () => {
      const before = '\n';
      const after = '\n\n\n';

      const actions = diffChars(before, after);
      const lines = groupActionsByLines(actions);
      expect(lines.length).toEqual(2);

      checkLineActions(lines[0], [['normal', '']]);
      checkLineActions(lines[1], [['added', '\n\n']]);
    });
  });

  describe('createDiffData', () => {
    it('Correctly creates diff lines for single line changes', () => {
      const before = 'hello world';
      const after = 'HELLO world';

      const lines = createDiffData(before, after);
      expect(lines.length).toEqual(2);
      expect(lines[0].type).toEqual('removed');
      checkLine(lines[0], 1, undefined, 'removed', [
        ['removed', 'hello'],
        ['normal', ' world'],
      ]);
      checkLine(lines[1], undefined, 1, 'added', [
        ['added', 'HELLO'],
        ['normal', ' world'],
      ]);
    });

    it('Correctly creates diff lines for single line deletions', () => {
      const before = 'a\nb';
      const after = 'b';

      const lines = createDiffData(before, after);
      expect(lines.length).toEqual(2);
      checkLine(lines[0], 1, undefined, 'removed', [['removed', 'a']]);
      checkLine(lines[1], 2, 1, 'normal', [['normal', 'b']]);
    });

    it('Correctly tracks line numbers for single-line additions', () => {
      const before = 'x\ny\nz';
      const after = 'x\ny\ny\nz';

      const lines = createDiffData(before, after);
      expect(lines.length).toEqual(4);

      checkLine(lines[0], 1, 1, 'normal', [['normal', 'x']]);
      checkLine(lines[1], 2, 2, 'normal', [['normal', 'y']]);
      checkLine(lines[2], undefined, 3, 'added', [['added', 'y']]);
      checkLine(lines[3], 3, 4, 'normal', [['normal', 'z']]);
    });

    it('Correctly tracks line numbers for multi-line additions', () => {
      const before = 'Hello there\nHello world\nhello again';
      const after = 'Hello there\nHello World\nanew line\nhello again\nhello again';

      const lines = createDiffData(before, after);
      expect(lines.length).toEqual(6);

      checkLine(lines[0], 1, 1, 'normal', [['normal', 'Hello there']]);
      checkLine(lines[1], 2, undefined, 'removed', [
        ['normal', 'Hello '],
        ['removed', 'w'],
        ['normal', 'orld'],
      ]);
      checkLine(lines[2], undefined, 2, 'added', [
        ['normal', 'Hello '],
        ['added', 'W'],
        ['normal', 'orld'],
      ]);
      checkLine(lines[3], undefined, 3, 'added', [['added', 'anew line']]);
      checkLine(lines[4], 3, 4, 'normal', [['normal', 'hello again']]);
      checkLine(lines[5], undefined, 5, 'added', [['added', 'hello again']]);
    });

    it('Correctly diffs empty line deletions', () => {
      const before = '\n\n';
      const after = '\n';

      const lines = createDiffData(before, after);
      expect(lines.length).toEqual(2);

      checkLine(lines[0], 1, 1, 'normal', [['normal', '']]);
      checkLine(lines[1], 2, undefined, 'removed', [['removed', '']]);
    });

    it('Correctly diffs empty line additions', () => {
      const before = '\n';
      const after = '\n\n\n';

      const lines = createDiffData(before, after);
      expect(lines.length).toEqual(3);

      checkLine(lines[0], 1, 1, 'normal', [['normal', '']]);
      checkLine(lines[1], undefined, 2, 'added', [['added', '']]);
      checkLine(lines[2], undefined, 3, 'added', [['added', '']]);
    });
  });
});
