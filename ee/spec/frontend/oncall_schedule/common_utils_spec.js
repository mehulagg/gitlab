import { ASSIGNEE_COLORS_COMBO } from 'ee/oncall_schedules/constants';
import {
  getFormattedTimezone,
  getParticipantsForSave,
  parseHour,
  parseRotationDate,
} from 'ee/oncall_schedules/utils/common_utils';
import mockTimezones from './mocks/mock_timezones.json';

describe('getFormattedTimezone', () => {
  it('formats the timezone', () => {
    const tz = mockTimezones[0];
    const expectedValue = `(UTC ${tz.formatted_offset}) ${tz.abbr} ${tz.name}`;
    expect(getFormattedTimezone(tz)).toBe(expectedValue);
  });
});

describe('getParticipantsForSave', () => {
  it('returns participant shift color data along with the username', () => {
    const participants = [{ username: 'user1' }, { username: 'user2' }, { username: 'user3' }];
    const result = getParticipantsForSave(participants);

    expect(result.length).toBe(participants.length);

    result.forEach((participant, index) => {
      const { colorWeight, colorPalette } = ASSIGNEE_COLORS_COMBO[index];
      const { username } = participants[index];
      expect(participant).toEqual({ username, colorWeight, colorPalette });
    });
  });
});

describe('parseRotationDate', () => {
  const scheduleTimezone = 'Pacific/Honolulu'; // UTC -10

  it('parses a rotation date according to the supplied timezone', () => {
    const dateTimeString = '2021-01-12T05:04:56.333Z';
    const rotationDate = parseRotationDate(dateTimeString, scheduleTimezone);

    expect(rotationDate).toStrictEqual({ date: new Date('2021-01-11T00:00:00.000Z'), time: 19 });
  });

  it('parses a rotation date at midnight without exceeding 24 hours', () => {
    const dateTimeString = '2021-01-12T10:00:00.000Z';
    const rotationDate = parseRotationDate(dateTimeString, scheduleTimezone);

    expect(rotationDate).toStrictEqual({ date: new Date('2021-01-12T00:00:00.000Z'), time: 0 });
  });
});

describe('parseHour', () => {
  it('parses a rotation active period hour string', () => {
    const hourString = '14:00';

    const hourInt = parseHour(hourString);

    expect(hourInt).toBe(14);
  });
});
