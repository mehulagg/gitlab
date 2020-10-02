export function loadCSSFile(path) {
  return new Promise(resolve => {
    const linkElement = document.createElement('link');
    linkElement.type = 'text/css';
    linkElement.rel = 'stylesheet';
    // eslint-disable-next-line @gitlab/require-i18n-strings
    linkElement.media = 'screen,print';
    linkElement.onload = () => {
      resolve();
    };
    linkElement.href = path;

    document.getElementsByTagName('head')[0].appendChild(linkElement);
  });
}
