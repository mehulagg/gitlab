// This is a helper module to lazily import the google APIs for the GKE cluster
// integration without introducing an indirect global dependency on an
// initialized window.gapi object.
export default () => {
  return new Promise((resolve, reject) => {
    // already loaded
    if (window.gapi) {
      resolve(window.gapi);
      return;
    }

    // if already loading, we instead queue up for results
    const existingCallback = window.onGapiLoad;
    if (existingCallback) {
      window.onGapiLoad = () => {
        existingCallback();
        resolve(window.gapi);
      };
      return;
    }
    // first time loading the script

    window.onGapiLoad = () => {
      resolve(window.gapi);
    };

    const script = document.createElement('script');
    // do not use script.onload, because gapi continues to load after the initial script load
    script.type = 'text/javascript';
    script.async = true;
    script.defer = true;
    script.src = 'https://apis.google.com/js/api.js?onload=onGapiLoad';
    script.onerror = reject;
    document.head.appendChild(script);
  });
};
