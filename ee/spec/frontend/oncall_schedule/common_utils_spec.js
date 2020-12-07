import { getFormattedTimezone } from 'ee/oncall_schedules/utils/common_utils';
import mockTimezones from './mocks/mockTimezones.json';

describe('getFormattedTimezone', () => {
  it('formats the timezone', () => {
    const tz = mockTimezones[0];
    const expectedValue = `(UTC ${tz.formatted_offset}) ${tz.abbr} ${tz.name}`;
    expect(getFormattedTimezone(tz)).toBe(expectedValue);
  });
});
