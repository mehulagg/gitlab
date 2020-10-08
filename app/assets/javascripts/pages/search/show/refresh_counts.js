import axios from '~/lib/utils/axios_utils';

function showCount(el, count) {
  el.textContent = count;
  el.classList.remove('hidden');
}

function refreshCount(el) {
  const { url } = el.dataset;

  return axios
    .get(url)
    .then(({ data }) => showCount(el, data.count))
    .catch(e => {
      // eslint-disable-next-line no-console
      console.error(`Failed to fetch search count from '${url}'.`, e);
    });
}

function unknownCount(el) {
  showCount(el, '?');
}

export default function refreshCounts() {
  const killswitch = document.querySelector('input[type="hidden"][name="with_counts"]');
  const elements = Array.from(document.querySelectorAll('.js-search-count'));
  const strategy = /true/i.test(killswitch.value) ? refreshCount : unknownCount;

  return Promise.all(elements.map(strategy));
}
