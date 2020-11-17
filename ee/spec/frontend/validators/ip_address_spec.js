import ipaddr from 'ipaddr.js';
import validateIpAddress from 'ee/validators/ip_address';

describe('validateIpAddress', () => {
  describe('when IP address is only integers', () => {
    it.each`
      address
      ${1}
      ${19}
      ${192}
    `('$address - returns false', ({ address }) => {
      expect(validateIpAddress(address)).toBe(false);
    });
  });

  describe('when IP address is in valid CIDR format', () => {
    it('returns true', () => {
      ipaddr.parseCIDR = jest.fn(() => [
        {
          octets: [192, 168, 0, 0],
        },
        24,
      ]);

      const result = validateIpAddress('192.168.0.0/24');

      expect(ipaddr.parseCIDR).toHaveBeenCalledWith('192.168.0.0/24');
      expect(result).toBe(true);
    });
  });

  describe('when IP address is not in valid CIDR format', () => {
    it('calls `ipaddr.isValid`', () => {
      ipaddr.parseCIDR = jest.fn(() => {
        throw new Error();
      });

      ipaddr.isValid = jest.fn();

      validateIpAddress('192.168.0.0');

      expect(ipaddr.isValid).toHaveBeenCalledWith('192.168.0.0');
    });
  });
});
