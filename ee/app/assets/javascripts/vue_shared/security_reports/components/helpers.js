import { EMPTY_BODY_MESSAGE } from './constants';

export const bodyWithFallBack = (body) => {
  // Return string if defined or blank string, otherwise fallback
  return body === '' ? '' : body || EMPTY_BODY_MESSAGE;
};
