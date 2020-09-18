import { sanitize } from 'dompurify';

// We currently load + parse the data from the issue app and related merge request
let cachedParsedData;

export const parseIssuableData = () => {
  try {
    if (cachedParsedData) return cachedParsedData;

    const initialDataEl = document.getElementById('js-issuable-app');

    const parsedData = JSON.parse(initialDataEl.dataset.initial.replace(/&quot;/g, '"'));
    parsedData.initialTitleHtml = sanitize(parsedData.initialTitleHtml);
    parsedData.initialDescriptionHtml = sanitize(parsedData.initialDescriptionHtml);

    cachedParsedData = parsedData;

    return parsedData;
  } catch (e) {
    console.error(e); // eslint-disable-line no-console

    return {};
  }
};

export default {};
