import { EMPTY_BODY_MESSAGE } from './constants';

export const bodyWithFallBack = (body) => body || EMPTY_BODY_MESSAGE;
