/* eslint-disable no-console */
import { getCLS, getFID, getLCP } from 'web-vitals';

const initVitalsLog = () => {
  const reportVital = data => {
    console.log(`${String.fromCodePoint(0x1f4c8)} ${data.name} : `, data);
  };

  console.log(
    `${String.fromCodePoint(
      0x1f4d1,
    )} To get the final web vital numbers reported you maybe need to switch away and back to the tab`,
  );
  getCLS(reportVital);
  getFID(reportVital);
  getLCP(reportVital);
};

const logUserTimingMetrics = () => {
  const metricsProcessor = list => {
    const entries = list.getEntries();
    entries.forEach(entry => {
      const { name, entryType, startTime, duration } = entry;
      const typeMapper = {
        mark: String.fromCodePoint(0x1f3af),
        measure: String.fromCodePoint(0x1f4d0),
      };
      console.group(`${typeMapper[entryType]} ${name}`);
      if (entryType === 'mark') {
        console.log(`Start time: ${startTime}`);
      } else if (entryType === 'measure') {
        console.log(`Duration: ${duration}`);
      }
      console.log(entry);
      console.groupEnd();
    });
  };
  const observer = new PerformanceObserver(metricsProcessor);
  observer.observe({ entryTypes: ['mark', 'measure'] });
};

const initPerformanceBarLog = () => {
  console.log(
    `%c ${String.fromCodePoint(0x1f98a)} GitLab performance bar`,
    'width:100%;background-color: #292961; color: #FFFFFF; font-size:24px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto; padding: 10px;display:block;padding-right: 100px;',
  );

  initVitalsLog();
  logUserTimingMetrics();
};

export default initPerformanceBarLog;
