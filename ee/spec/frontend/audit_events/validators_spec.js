import { sample } from 'lodash';
import { AVAILABLE_TOKEN_TYPES } from 'ee/audit_events/constants';
import { filterTokenOptionsValidator } from 'ee/audit_events/validators';

describe('filterTokenOptionsValidator', () => {
  it('returns true when the input contains a valid token type', () => {
    const input = [{ type: sample(AVAILABLE_TOKEN_TYPES) }];
    expect(filterTokenOptionsValidator(input)).toEqual(true);
  });

  it('returns false when the input contains an invalid token type', () => {
    const input = [{ type: 'InvalidType' }];
    expect(filterTokenOptionsValidator(input)).toEqual(false);
  });
});
