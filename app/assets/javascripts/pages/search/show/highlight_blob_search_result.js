export default () => {
  const highlightLineClass = 'hll';
  const contentBody = document.getElementById('content-body');
  const blobs = contentBody.querySelectorAll('.blob-result');

  blobs.forEach(blob => {
    const { highlightLine } = blob.querySelector('[data-highlight-line]').dataset;
    if (highlightLine) {
      const lines = blob.querySelectorAll('.line');
      lines[highlightLine].classList.add(highlightLineClass);
    }
  });
};
