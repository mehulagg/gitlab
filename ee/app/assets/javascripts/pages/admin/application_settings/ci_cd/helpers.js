/**
 * Filters [gitlabCiYmls] based on a given [searchTerm].
 * Yml catagories with no items after filtering are not included in the returned object.
 * @param {Object} gitlabCiYmls - { <categoryName>: [{ name, id }] }
 * @param {String} searchTerm
 * @returns {Object}
 */
export function filterGitlabCiYmls(gitlabCiYmls, searchTerm) {
  return Object.keys(gitlabCiYmls).reduce((filteredYmls, category) => {
    const categoryYmls = gitlabCiYmls[category].filter((yml) =>
      yml.name.toLowerCase().startsWith(searchTerm),
    );

    if (categoryYmls.length > 0) {
      Object.assign(filteredYmls, {
        [category]: categoryYmls,
      });
    }

    return filteredYmls;
  }, {});
}
