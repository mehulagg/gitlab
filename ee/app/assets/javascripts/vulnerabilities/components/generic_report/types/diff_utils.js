/**
 * Use the function `createDiffData` to create diff lines for rendering
 * diffs
 */

import { diffChars } from 'diff';

export function splitAction(action) {
  const splitValues = action.value.split(/(\n)/);
  if (
    splitValues.length >= 2 &&
    splitValues[splitValues.length - 1] === '' &&
    splitValues[splitValues.length - 2] === '\n'
  ) {
    splitValues.pop();
  }
  const res = [];
  splitValues.forEach(splitValue => {
    res.push({
      added: action.added,
      removed: action.removed,
      value: splitValue,
    });
  });
  return res;
}

function setLineNumbers(lines) {
  let beforeLineNo = 1;
  let afterLineNo = 1;
  lines.forEach(l => {
    const line = l;
    if (line.type === 'normal') {
      line.old_line = beforeLineNo;
      line.new_line = afterLineNo;
      beforeLineNo += 1;
      afterLineNo += 1;
    } else if (line.type === 'removed') {
      line.old_line = beforeLineNo;
      beforeLineNo += 1;
    } else if (line.type === 'added') {
      line.new_line = afterLineNo;
      afterLineNo += 1;
    }
  });
}

function splitLinesInline(lines) {
  const res = [];
  const createLine = type => {
    return { type, actions: [], old_line: undefined, new_line: undefined };
  };
  const hasNonEmpty = (line, type) => {
    let typeCount = 0;
    for (let i = 0; i < line.actions.length; i += 1) {
      const action = line.actions[i];
      if (action[type]) {
        typeCount += 1;
        if (action.value !== '') {
          return true;
        }
      }
    }
    return typeCount === line.actions.length;
  };

  lines.forEach(line => {
    const beforeLine = createLine('normal');
    let afterLine = createLine('added');

    let totalNormal = 0;
    let totalRemoved = 0;
    let totalAdded = 0;
    const maybeAddAfter = () => {
      if (totalAdded > 0 && hasNonEmpty(afterLine, 'added')) {
        res.push(afterLine);
      }
    };

    line.actions.forEach(action => {
      if (!action.added && !action.removed) {
        totalNormal += 1;
        beforeLine.actions.push(action);
        afterLine.actions.push(action);
      } else if (action.removed) {
        totalRemoved += 1;
        beforeLine.actions.push(action);
        beforeLine.type = 'removed';
      } else if (action.added) {
        splitAction(action).forEach(split => {
          if (split.value === '\n') {
            maybeAddAfter();
            totalAdded = 0;
            afterLine = createLine('added');
          } else {
            totalAdded += 1;
            afterLine.actions.push(split);
          }
        });
      }
    });
    if (totalNormal > 0 || totalRemoved > 0) {
      res.push(beforeLine);
    }
    maybeAddAfter();
  });

  setLineNumbers(res);
  return res;
}

export function groupActionsByLines(actions) {
  const res = [];
  let currLine = null;
  const newLine = () => {
    if (currLine !== null) {
      res.push(currLine);
    }
    currLine = { actions: [] };
  };
  newLine();

  actions.forEach(action => {
    if (action.added) {
      currLine.actions.push(action);
    } else {
      splitAction(action).forEach(split => {
        if (split.value === '\n') {
          newLine();
        } else {
          currLine.actions.push(split);
        }
      });
    }
  });
  if (currLine.actions.length > 0) {
    newLine();
  }
  return res;
}

/**
 * Create an array of line objects of the form
 *   {
 *     type: normal | added | removed,
 *     actions: [], // array of action objects (see below)
 *     new_line: undefined or number,
 *     old_line: undefined or number,
 *   }
 *
 * Action objects have the form
 *
 *   {
 *     added: true | false,
 *     removed: true | false,
 *     value: string
 *   }
 */
export function createDiffData(before, after) {
  const opts = {
    ignoreWhitespace: false,
    newlineIsToken: true,
  };
  const actions = diffChars(before, after, opts);
  const lines = groupActionsByLines(actions);
  return splitLinesInline(lines);
}
