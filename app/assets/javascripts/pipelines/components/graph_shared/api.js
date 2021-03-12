import axios from '~/lib/utils/axios_utils';
import { reportToSentry } from '../graph/utils';

export const reportPerformance = (path, stats) => {
  console.log('report called');
  axios.post(path, stats).then(data => console.log(data)).catch((err) => {
    reportToSentry('links_inner_perf', `error: ${err}`);
  });
};
