import { setTestTimeout } from 'helpers/timeout';

beforeEach(() => {
  window.gon = {
    api_version: 'v4',
    relative_url_root: '',
  };

  setTestTimeout(30000);
  jest.useRealTimers();
});

afterEach(() => {
  jest.useFakeTimers();
});
