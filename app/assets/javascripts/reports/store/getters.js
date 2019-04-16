import { LOADING, ERROR, SUCCESS, STATUS_FAILED } from '../constants';

export default {
  summaryStatus: state => {
    if (state.isLoading) {
      return LOADING;
    }

    if (state.hasError || state.status === STATUS_FAILED) {
      return ERROR;
    }

    return SUCCESS;
  },
};
