import { isSameVulnerability } from 'ee/security_dashboard/store/modules/vulnerabilities/utils';
import mockData from './data/mock_data_vulnerabilities';

describe('Vulnerabilities utils', () => {
  const clone = (serializable) => JSON.parse(JSON.stringify(serializable));
  const vuln = clone(mockData[0]);
  const vulnWithNewLocation = { ...clone(vuln), location: { foo: 1 } };
  const vulnWithNewIdentifier = { ...clone(vuln), identifiers: [{ foo: 1 }] };

  describe('isSameVulnerability', () => {
    describe.each`
      description                        | vulnerability | other                    | result
      ${'identical vulnerabilities'}     | ${vuln}       | ${vuln}                  | ${true}
      ${'cloned vulnerabilities'}        | ${vuln}       | ${clone(vuln)}           | ${true}
      ${'different locations'}           | ${vuln}       | ${vulnWithNewLocation}   | ${false}
      ${'different primary identifiers'} | ${vuln}       | ${vulnWithNewIdentifier} | ${false}
      ${'cloned non-vulnerabilities'}    | ${{ foo: 1 }} | ${{ foo: 1 }}            | ${false}
      ${'null values'}                   | ${null}       | ${null}                  | ${false}
      ${'undefined values'}              | ${undefined}  | ${undefined}             | ${false}
    `('given $description', ({ vulnerability, other, result }) => {
      it(`returns ${result}`, () => {
        expect(isSameVulnerability(vulnerability, other)).toBe(result);
      });
    });
  });
});
