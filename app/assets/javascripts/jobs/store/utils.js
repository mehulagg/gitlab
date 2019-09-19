import _ from 'underscore';
import { duration } from 'moment-mini';
/**
 * Adds the line number property
 * @param Object line
 * @param Number lineNumber
 */
export const parseLine = (line = {}, lineNumber) => ({
  ...line,
  lineNumber,
});

export const parseHeaderLine = (line = {}, lineNumber) => ({
  isClosed: true,
  isHeader: true,
  line: parseLine(line, lineNumber),
  lines: [],
});

export const parseNestedSection = (parent, line, lineNumber) => {
  if (line.content.length) {
    parent.lines.push(parseHeaderLine(line, lineNumber));
  }
};

export const addDurationToHeader = (data, durationLine) => {
  _.flatten(data).find(el => {
    debugger;
    if (_.intersection(el.sections, durationLine.sections)) {
      el.section_duration = durationLine.section_duration;
    }
  });
};

export const addNestedLine = (last, line, lineNumber) => {
  _.flatten(last.lines).find(el => {
    if (_.intersection(el.sections, line.sections)) {
      if (line.content.length) {
        el.lines.push(parseLine(line, lineNumber));
      }
    }
  });
};

/**
 * Parses the job log content into a structure usable by the template
 *
 * For collaspible lines (section_header = true):
 *    - creates a new array to hold the lines that are collpasible,
 *    - adds a isClosed property to handle toggle
 *    - adds a isHeader property to handle template logic
 *    - adds the section_duration
 * For each line:
 *    - adds the index as  lineNumber
 *
 * @param {Array} lines
 * @returns {Array}
 */
export const logLinesParser = (lines = [], lineNumberStart) =>
  lines.reduce((acc, line, index) => {
    const lineNumber = lineNumberStart ? lineNumberStart + index : index;
    const last = acc[acc.length - 1];

    if (line.section_header) {
      if (last && last.isHeader && _.intersection(line.sections, last.line.sections)) {
        parseNestedSection(last, line, lineNumber);
      } else {
        acc.push(parseHeaderLine(line, lineNumber));
      }
    } else if (last && last.isHeader) {
      addNestedLine(last, line, lineNumber);
    } else if (line.section_duration) {
      addDurationToHeader(acc, line);
    } else if (line.content.length) {
      acc.push(parseLine(line, lineNumber));
    }

    return acc;
  }, []);

/**
 * When the trace is not complete, backend may send the last received line
 * in the new response.
 *
 * We need to check if that is the case by looking for the offset property
 * before parsing the incremental part
 *
 * @param array originalTrace
 * @param array oldLog
 * @param array newLog
 */
export const updateIncrementalTrace = (originalTrace = [], oldLog = [], newLog = []) => {
  const firstLine = newLog[0];
  const firstLineOffset = firstLine.offset;

  // We are going to return a new array,
  // let's make a shallow copy to make sure we
  // are not updating the state outside of a mutation first.
  const cloneOldLog = [...oldLog];

  const lastIndex = cloneOldLog.length - 1;
  const lastLine = cloneOldLog[lastIndex];

  // The last line may be inside a collpasible section
  // If it is, we use the not parsed saved log, remove the last element
  // and parse the first received part togheter with the incremental log
  if (
    lastLine.isHeader &&
    (lastLine.line.offset === firstLineOffset ||
      (lastLine.lines.length &&
        lastLine.lines[lastLine.lines.length - 1].offset === firstLineOffset))
  ) {
    const cloneOriginal = [...originalTrace];
    cloneOriginal.splice(cloneOriginal.length - 1);
    return logLinesParser(cloneOriginal.concat(newLog));
  } else if (lastLine.offset === firstLineOffset) {
    cloneOldLog.splice(lastIndex);
    return cloneOldLog.concat(logLinesParser(newLog, cloneOldLog.length));
  }
  // there are no matches, let's parse the new log and return them together
  return cloneOldLog.concat(logLinesParser(newLog, cloneOldLog.length));
};

export const isNewJobLogActive = () => gon && gon.features && gon.features.jobLogJson;
