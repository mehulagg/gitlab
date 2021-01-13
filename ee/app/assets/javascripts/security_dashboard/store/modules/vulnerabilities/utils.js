import { isEqual } from 'lodash';

const isVulnerabilityLike = (object) =>
  Boolean(object && object.location && object.identifiers && object.identifiers[0]);

/**
 * Determines whether the provided objects represent the same vulnerability.
 * @param {Object} vulnerability A vulnerability occurrence
 * @param {Object} other Another vulnerability occurrence
 * @returns {boolean}
 */
export const isSameVulnerability = (vulnerability, other) => {
  if (!isVulnerabilityLike(vulnerability) || !isVulnerabilityLike(other)) {
    return false;
  }

  // The `[location_fingerprint, identifiers[0]]` tuple is currently the most
  // correct/robust set of data to compare to see if two objects represent the
  // same vulnerability[1]. Unfortunately, `location_fingerprint` isn't exposed
  // by the API yet, so we fall back to a slower deep equality comparison on
  // `location` (which is a superset of `location_fingerprint`) if the former
  // isn't present.
  //
  // [1]: https://gitlab.com/gitlab-org/gitlab/issues/7586
  let isLocationEqual = false;
  if (vulnerability.location_fingerprint && other.location_fingerprint) {
    isLocationEqual = vulnerability.location_fingerprint === other.location_fingerprint;
  } else {
    isLocationEqual = isEqual(vulnerability.location, other.location);
  }

  return isLocationEqual && isEqual(vulnerability.identifiers[0], other.identifiers[0]);
};
