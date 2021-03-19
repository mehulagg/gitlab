import ipaddr from 'ipaddr.js';

export default (address) => {
  // Reject IP addresses that are only integers to match Ruby IPAddr
  // https://github.com/whitequark/ipaddr.js/issues/7#issuecomment-158545695
  if (/^\d+$/.exec(address)) {
    return false;
  }

  try {
    // Checks if Valid IPv4/IPv6 (CIDR) - Throws if not
    return Boolean(ipaddr.parseCIDR(address));
  } catch (e) {
    // Checks if Valid IPv4/IPv6 (Non-CIDR) - Does not Throw
    return ipaddr.isValid(address);
  }
};
