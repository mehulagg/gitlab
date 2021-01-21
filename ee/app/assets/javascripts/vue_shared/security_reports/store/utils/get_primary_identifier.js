import { PRIMARY_IDENTIFIER_TYPE } from 'ee/security_dashboard/store/constants';
/**
 * Finds the name of the primary identifier or returns the name of the first identifier
 *
 * @param {Array} identifiers all available identifiers
 * @returns {String} the primary identifier's name
 */
const getPrimaryIdentifier = (identifiers = [], property) => {
  const identifier = identifiers.find((value) => value[property] === PRIMARY_IDENTIFIER_TYPE);
  return identifier?.name || identifiers[0]?.name || '';
};

export default getPrimaryIdentifier;
