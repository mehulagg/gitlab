import { validateTimeout, validateAllowedIp } from 'ee/geo_settings/validations';
import { STRING_OVER_255 } from './mock_data';

describe('Geo Settings Validations', () => {
  let res = '';

  describe.each`
    data      | errorMessage
    ${null}   | ${"Connection timeout can't be blank"}
    ${''}     | ${"Connection timeout can't be blank"}
    ${'asdf'} | ${'Connection timeout must be a number'}
    ${0}      | ${'Connection timeout should be between 1-120'}
    ${121}    | ${'Connection timeout should be between 1-120'}
    ${10}     | ${''}
  `(`validateTimeout`, ({ data, errorMessage }) => {
    beforeEach(() => {
      res = validateTimeout(data);
    });

    it(`return ${errorMessage} when data is ${data}`, () => {
      expect(res).toBe(errorMessage);
    });
  });

  describe.each`
    data               | errorMessage
    ${null}            | ${"Allowed Geo IP can't be blank"}
    ${''}              | ${"Allowed Geo IP can't be blank"}
    ${STRING_OVER_255} | ${'Allowed Geo IP should be between 1 and 255 characters'}
    ${'asdf'}          | ${'Allowed Geo IP should contain valid IP addresses'}
    ${'1.1.1.1, asdf'} | ${'Allowed Geo IP should contain valid IP addresses'}
    ${'asdf, 1.1.1.1'} | ${'Allowed Geo IP should contain valid IP addresses'}
    ${'1.1.1.1'}       | ${''}
    ${'::/0'}          | ${''}
    ${'1.1.1.1, ::/0'} | ${''}
  `(`validateAllowedIp`, ({ data, errorMessage }) => {
    beforeEach(() => {
      res = validateAllowedIp(data);
    });

    it(`return ${errorMessage} when data is ${data}`, () => {
      expect(res).toBe(errorMessage);
    });
  });
});
