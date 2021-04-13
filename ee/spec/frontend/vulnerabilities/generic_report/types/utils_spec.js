import {
  REPORT_TYPE_LIST,
  REPORT_TYPE_URL,
} from 'ee/vulnerabilities/components/generic_report/types/constants';
import { filterTypesAndLimitListDepth } from 'ee/vulnerabilities/components/generic_report/types/utils';

const MOCK_REPORT_TYPE_UNSUPPORTED = 'MOCK_REPORT_TYPE_UNSUPPORTED';

const TEST_DATA = {
  url: {
    type: REPORT_TYPE_URL,
    name: 'url1',
  },
  list: {
    type: REPORT_TYPE_LIST,
    name: 'rootList',
    items: [
      { type: REPORT_TYPE_URL, name: 'url2' },
      {
        type: REPORT_TYPE_LIST,
        name: 'listDepthOne',
        items: [
          { type: REPORT_TYPE_URL, name: 'url3' },
          {
            type: REPORT_TYPE_LIST,
            name: 'listDepthTwo',
            items: [
              { type: REPORT_TYPE_URL, name: 'url4' },
              {
                type: REPORT_TYPE_LIST,
                name: 'listDepthThree',
                items: [
                  { type: REPORT_TYPE_URL, name: 'url5' },
                  { type: MOCK_REPORT_TYPE_UNSUPPORTED },
                ],
              },
              { type: MOCK_REPORT_TYPE_UNSUPPORTED },
            ],
          },
          { type: MOCK_REPORT_TYPE_UNSUPPORTED },
        ],
      },
      { type: MOCK_REPORT_TYPE_UNSUPPORTED },
    ],
  },
};

describe('ee/vulnerabilities/components/generic_report/types/utils', () => {
  describe('filterTypesAndLimitListDepth', () => {
    const getRootList = (reportsData) => reportsData.list;
    const getListWithDepthOne = (reportsData) => reportsData.list.items[1];
    const getListWithDepthTwo = (reportsData) => reportsData.list.items[1].items[1];
    const includesType = (type) => (items) =>
      items.find(({ type: currentType }) => currentType === type) !== undefined;
    const includesListItem = includesType(REPORT_TYPE_LIST);
    const includesUnsupportedType = includesType(MOCK_REPORT_TYPE_UNSUPPORTED);

    describe.each`
      depth | getListAtCurrentDepth
      ${1}  | ${getRootList}
      ${2}  | ${getListWithDepthOne}
      ${3}  | ${getListWithDepthTwo}
    `('with nested lists at depth: "$depth"', ({ depth, getListAtCurrentDepth }) => {
      const filteredData = filterTypesAndLimitListDepth(TEST_DATA, { maxDepth: depth });

      it('filters list items', () => {
        expect(includesListItem(getListAtCurrentDepth(TEST_DATA).items)).toBe(true);
        expect(includesListItem(getListAtCurrentDepth(filteredData).items)).toBe(false);
      });

      it('filters items with types that are not supported', () => {
        expect(includesUnsupportedType(getListAtCurrentDepth(TEST_DATA).items)).toBe(true);
        expect(includesUnsupportedType(getListAtCurrentDepth(filteredData).items)).toBe(false);
      });
    });
  });
});
