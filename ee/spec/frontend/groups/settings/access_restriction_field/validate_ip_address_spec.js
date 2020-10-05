import ipaddr from 'ipaddr.js';
import validateRestrictedIpAddress from 'ee/groups/settings/access_restriction_field/validate_ip_address';

describe('validateRestrictedIpAddress', () => {
  describe('when IP address is not valid', () => {
    it('returns an error message', () => {
      ipaddr.isValid = jest.fn(() => false);

      const result = validateRestrictedIpAddress('foo bar');

      expect(ipaddr.isValid).toHaveBeenCalledWith('foo bar');
      expect(result).toBe(`foo bar is an invalid IP address range`);
    });
  });

  describe('when IP address is valid', () => {
    it('returns an empty string', () => {
      ipaddr.isValid = jest.fn(() => true);

      const result = validateRestrictedIpAddress('192.168.0.0');

      expect(ipaddr.isValid).toHaveBeenCalledWith('192.168.0.0');
      expect(result).toBe('');
    });
  });
});
