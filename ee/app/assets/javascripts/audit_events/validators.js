import { AVAILABLE_TOKEN_TYPES } from './constants';

export function filterTokenOptionsValidator(filterTokenOptions) {
  return filterTokenOptions
    .map(({ type }) => type)
    .every((type) => AVAILABLE_TOKEN_TYPES.includes(type));
}
