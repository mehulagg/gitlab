import validateIpAddress from 'ee/validators/ip_address';
import { s__ } from '~/locale';

const validateIP = data => {
  let addresses = data.replace(/\s/g, '').split(',');

  addresses = addresses.map(address => validateIpAddress(address));

  return !addresses.some(a => !a);
};

export const validateTimeout = data => {
  if (!data && data !== 0) {
    return s__("Geo|Connection timeout can't be blank");
  } else if (data && Number.isNaN(Number(data))) {
    return s__('Geo|Connection timeout must be a number');
  } else if (data < 1 || data > 120) {
    return s__('Geo|Connection timeout should be between 1-120');
  }

  return '';
};

export const validateAllowedIp = data => {
  if (!data) {
    return s__("Geo|Allowed Geo IP can't be blank");
  } else if (data.length > 255) {
    return s__('Geo|Allowed Geo IP should be between 1 and 255 characters');
  } else if (!validateIP(data)) {
    return s__('Geo|Allowed Geo IP should contain valid IP addresses');
  }

  return '';
};
