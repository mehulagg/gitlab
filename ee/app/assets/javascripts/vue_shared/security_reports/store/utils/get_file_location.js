/**
 * Parses the location object on a vulnerability to get a url
 * @param {Object} location
 * @returns {(String|null)} The parsed url or null if unparsable
 */
const getFileLocation = (location = {}) => {
  const { hostname, path } = location;
  if (typeof hostname !== 'string' || typeof path !== 'string') {
    return null;
  }
  return `${hostname}${path}`;
};

export default getFileLocation;
