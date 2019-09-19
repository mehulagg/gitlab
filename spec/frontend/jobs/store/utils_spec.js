import {
  logLinesParser,
  updateIncrementalTrace,
  parseLine,
  parseHeaderLine,
  parseNestedSection,
} from '~/jobs/store/utils';
import {
  utilsMockData,
  originalTrace,
  regularIncremental,
  regularIncrementalRepeated,
  headerTrace,
  headerTraceIncremental,
  collapsibleTrace,
  collapsibleTraceIncremental,
  nestedSectionInput,
  nestedSectionOutput,
} from '../components/log/mock_data';

describe('Jobs Store Utils', () => {
  describe('parseLine', () => {
    it('returns a new object with the lineNumber key added to the provided line object', () => {
      const line = { content: [{ text: 'foo' }] };
      const parsed = parseLine(line, 1);
      expect(parsed.content).toEqual(line.content);
      expect(parsed.lineNumber).toEqual(1);
    });
  });

  describe('parseHeaderLine', () => {
    it('returns a new object with the header keys and the provided line parsed', () => {
      const headerLine = { content: [{ text: 'foo' }] };
      const parsedHeaderLine = parseHeaderLine(headerLine, 2);

      expect(parsedHeaderLine).toEqual({
        isClosed: true,
        isHeader: true,
        line: {
          ...headerLine,
          lineNumber: 2,
        },
        lines: [],
      });
    });
  });

  describe('parseNestedSection', () => {
    it('pushes a parsed header line when content has data', () => {
      const headerLine = { content: [{ text: 'foo' }] };
      const parsedHeaderLine = parseHeaderLine(headerLine, 2);
      const parent = {
        isClosed: true,
        isHeader: true,
        line: {
          content: [{ text: 'bar' }],
          lineNumber: 1,
        },
        lines: [],
      };

      parseNestedSection(parent, headerLine, 2);
      expect(parent.lines).toEqual([parsedHeaderLine]);
    });

    it('does not push when content has no data', () => {
      const headerLine = { content: [] };
      const parent = {
        isClosed: true,
        isHeader: true,
        line: {
          content: [{ text: 'bar' }],
          lineNumber: 1,
        },
        lines: [],
      };

      parseNestedSection(parent, headerLine, 2);

      expect(parent).toEqual(parent);
    });
  });

  describe('addDurationToHeader', () => {});

  describe('addNestedLine', () => {});

  describe('logLinesParser', () => {
    let result;

    beforeEach(() => {
      result = logLinesParser(utilsMockData);
    });

    describe('regular line', () => {
      it('adds a lineNumber property with correct index', () => {
        expect(result[0].lineNumber).toEqual(0);
        expect(result[1].line.lineNumber).toEqual(1);
      });
    });

    describe('collpasible section', () => {
      it('adds a `isClosed` property', () => {
        expect(result[1].isClosed).toEqual(true);
      });

      it('adds a `isHeader` property', () => {
        expect(result[1].isHeader).toEqual(true);
      });

      it('creates a lines array property with the content of the collpasible section', () => {
        expect(result[1].lines.length).toEqual(2);
        expect(result[1].lines[0].content).toEqual(utilsMockData[2].content);
        expect(result[1].lines[1].content).toEqual(utilsMockData[3].content);
      });
    });

    describe('section duration', () => {
      it('adds the section information to the header section', () => {
        expect(result[1].section_duration).toEqual(utilsMockData[4].section_duration);
      });

      it('does not add section duration as a line', () => {
        expect(result[1].lines.includes(utilsMockData[4])).toEqual(false);
      });
    });
  });

  describe('nested sections', () => {
    it('parses the log with nested sections', () => {
      expect(logLinesParser(nestedSectionInput)).toEqual(nestedSectionOutput);
    });
  });

  describe('updateIncrementalTrace', () => {
    describe('without repeated section', () => {
      it('concats and parses both arrays', () => {
        const oldLog = logLinesParser(originalTrace);
        const result = updateIncrementalTrace(originalTrace, oldLog, regularIncremental);

        expect(result).toEqual([
          {
            offset: 1,
            content: [
              {
                text: 'Downloading',
              },
            ],
            lineNumber: 0,
          },
          {
            offset: 2,
            content: [
              {
                text: 'log line',
              },
            ],
            lineNumber: 1,
          },
        ]);
      });
    });

    describe('with regular line repeated offset', () => {
      it('updates the last line and formats with the incremental part', () => {
        const oldLog = logLinesParser(originalTrace);
        const result = updateIncrementalTrace(originalTrace, oldLog, regularIncrementalRepeated);

        expect(result).toEqual([
          {
            offset: 1,
            content: [
              {
                text: 'log line',
              },
            ],
            lineNumber: 0,
          },
        ]);
      });
    });

    describe('with header line repeated', () => {
      it('updates the header line and formats with the incremental part', () => {
        const oldLog = logLinesParser(headerTrace);
        const result = updateIncrementalTrace(headerTrace, oldLog, headerTraceIncremental);

        expect(result).toEqual([
          {
            isClosed: true,
            isHeader: true,
            line: {
              offset: 1,
              section_header: true,
              content: [
                {
                  text: 'updated log line',
                },
              ],
              sections: ['section'],
              lineNumber: 0,
            },
            lines: [],
          },
        ]);
      });
    });

    describe('with collapsible line repeated', () => {
      it('updates the collapsible line and formats with the incremental part', () => {
        const oldLog = logLinesParser(collapsibleTrace);
        const result = updateIncrementalTrace(
          collapsibleTrace,
          oldLog,
          collapsibleTraceIncremental,
        );

        expect(result).toEqual([
          {
            isClosed: true,
            isHeader: true,
            line: {
              offset: 1,
              section_header: true,
              content: [
                {
                  text: 'log line',
                },
              ],
              sections: ['section'],
              lineNumber: 0,
            },
            lines: [
              {
                offset: 2,
                content: [
                  {
                    text: 'updated log line',
                  },
                ],
                sections: ['section'],
                lineNumber: 1,
              },
            ],
          },
        ]);
      });
    });
  });
});
