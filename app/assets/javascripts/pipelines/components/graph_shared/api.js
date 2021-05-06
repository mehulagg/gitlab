import axios from '~/lib/utils/axios_utils';
import { reportToSentry } from '../../utils';

export const reportPerformance = (path, stats) => {
  // FIXME: This is a workaround for a flaky test where `path`
  // was undefined and it ended up calling axios instead of
  // axios-mock-adapter
  if (!path) {
    return;
  }

  axios.post(path, stats).catch((err) => {
    reportToSentry('links_inner_perf', `error: ${err}`);
  });
};
