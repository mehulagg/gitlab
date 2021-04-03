import validateIpAddress from 'ee/validators/ip_address';
import { __, sprintf } from '~/locale';

export default (address) => {
  if (!validateIpAddress(address)) {
    return sprintf(__('%{address} is an invalid IP address range'), { address });
  }

  return '';
};
