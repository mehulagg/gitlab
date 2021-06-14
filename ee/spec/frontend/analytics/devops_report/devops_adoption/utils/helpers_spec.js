import { shouldPollTableData } from 'ee/analytics/devops_report/devops_adoption/utils/helpers';
import { devopsAdoptionNamespaceData } from '../mock_data';

describe('shouldPollTableData', () => {
  const { nodes: pendingData } = devopsAdoptionNamespaceData;
  const comepleteData = [pendingData[0]];
  const mockDate = '2020-07-06T00:00:00.000Z';
  const previousDay = '2020-07-05T00:00:00.000Z';

  it.each`
    scenario                                                       | segments         | timestamp      | openModal | expected
    ${'no segment data'}                                           | ${[]}            | ${mockDate}    | ${false}  | ${true}
    ${'no timestamp'}                                              | ${comepleteData} | ${null}        | ${false}  | ${true}
    ${'open modal'}                                                | ${comepleteData} | ${mockDate}    | ${true}   | ${false}
    ${'segment data, timestamp is today, modal is closed'}         | ${comepleteData} | ${mockDate}    | ${false}  | ${false}
    ${'segment data, timestamp is yesterday, modal is closed'}     | ${comepleteData} | ${previousDay} | ${false}  | ${true}
    ${'segment data, timestamp is today, modal is open'}           | ${comepleteData} | ${mockDate}    | ${true}   | ${false}
    ${'pending segment data, timestamp is today, modal is closed'} | ${pendingData}   | ${mockDate}    | ${false}  | ${true}
  `('returns $expected when $scenario', ({ segments, timestamp, openModal, expected }) => {
    expect(shouldPollTableData({ segments, timestamp, openModal })).toBe(expected);
  });
});
