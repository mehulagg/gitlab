// Limit the number of vulnerabilities to display so as to avoid jank.
// In practice, this limit will probably never be reached, since the
// largest number of vulnerabilities we've seen one dependency have is 20.
// eslint-disable-next-line import/prefer-default-export
export const MAX_DISPLAYED_VULNERABILITIES_PER_DEPENDENCY = 50;
