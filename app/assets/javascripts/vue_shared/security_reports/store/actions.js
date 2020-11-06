import pollUntilComplete from '~/lib/utils/poll_until_complete';
import axios from '~/lib/utils/axios_utils';

export const fetchDiffData = (state, endpoint, category) => {
    const requests = [pollUntilComplete(endpoint)];

    if (state.canReadVulnerabilityFeedback) {
        requests.push(axios.get(state.vulnerabilityFeedbackPath, { params: { category } }));
    }

    return Promise.all(requests).then(([diffResponse, enrichResponse]) => ({
        diff: diffResponse.data,
        enrichData: enrichResponse?.data ?? [],
    }));
};