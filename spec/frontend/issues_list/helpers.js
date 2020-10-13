import { TEST_HOST } from 'helpers/test_constants';

export const TEST_LOCATION = `${TEST_HOST}/issues`;

export const setUrl = query => {
    window.location.href = `${TEST_LOCATION}${query}`;
    window.location.search = query;
  };