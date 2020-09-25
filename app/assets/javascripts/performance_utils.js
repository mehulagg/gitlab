export const performanceMeasureAfterRendering = ({ marks = [], measures = [] } = {}) => {
  if (marks.length) {
    marks.forEach(mark => {
      if (!performance.getEntriesByName(mark).length) {
        window.requestAnimationFrame(() => {
          performance.mark(mark);
          measures.forEach(measure => {
            window.requestAnimationFrame(() => {
              performance.measure(measure.name, measure.start, measure.end);
            });
          });
        });
      }
    });
  } else {
    measures.forEach(measure => {
      window.requestAnimationFrame(() => {
        performance.measure(measure.name, measure.start, measure.end);
      });
    });
  }
};
export const performanceMark = mark => {
  performance.mark(mark);
};
