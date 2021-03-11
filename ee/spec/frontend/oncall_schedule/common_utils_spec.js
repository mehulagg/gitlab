import { ASSIGNEE_COLORS_COMBO } from 'ee/oncall_schedules/constants';
import {
  getFormattedTimezone,
  getParticipantsForSave,
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
