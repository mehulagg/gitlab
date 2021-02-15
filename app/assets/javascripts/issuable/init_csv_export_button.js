import Vue from 'vue';
import CsvExportButton from './components/csv_export_button.vue';

export default () => {
  const el = document.querySelector('.js-csv-export-button');

  if (!el) return null;

  const { issuableType, issuableCount, email, exportCsvPath } = el.dataset;

  console.log(el.dataset, issuableType, issuableCount, email, exportCsvPath);

  return new Vue({
    el,
    provide: {
      issuableType,
      issuableCount,
      email,
      exportCsvPath,
    },
    render(h) {
      return h(CsvExportButton);
    },
  });
};
