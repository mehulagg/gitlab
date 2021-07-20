import { shouldPollTableData } from 'ee/analytics/devops_report/devops_adoption/utils/helpers';
import { devopsAdoptionNamespaceData } from '../mock_data';

describe('shouldPollTableData', () => {
  const { nodes: pendingData } = devopsAdoptionNamespaceData;
  const comepleteData = [pendingData[0]];
  const mockDate = '2020-07-06T00:00:00.000Z';
  const previousDay = '2020-07-05T00:00:00.000Z';

  it.each`
    scenario                                                          | enabledNamespaces | timestamp      | openModal | expected
    ${'no namespaces data'}                                           | ${[]}             | ${mockDate}    | ${false}  | ${true}
    ${'no timestamp'}                                                 | ${comepleteData}  | ${null}        | ${false}  | ${true}
    ${'open modal'}                                                   | ${comepleteData}  | ${mockDate}    | ${true}   | ${false}
    ${'namespaces data, timestamp is today, modal is closed'}         | ${comepleteData}  | ${mockDate}    | ${false}  | ${false}
    ${'namespaces data, timestamp is yesterday, modal is closed'}     | ${comepleteData}  | ${previousDay} | ${false}  | ${true}
    ${'namespaces data, timestamp is today, modal is open'}           | ${comepleteData}  | ${mockDate}    | ${true}   | ${false}
    ${'pending namespaces data, timestamp is today, modal is closed'} | ${pendingData}    | ${mockDate}    | ${false}  | ${true}
  `('returns $expected when $scenario', ({ enabledNamespaces, timestamp, openModal, expected }) => {
    expect(shouldPollTableData({ enabledNamespaces, timestamp, openModal })).toBe(expected);
  });
});
