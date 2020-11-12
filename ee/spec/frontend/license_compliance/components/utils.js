export const makeLicense = (changes = {}) => ({
  name: 'Apache 2.0',
  url: 'http://www.apache.org/licenses/LICENSE-2.0.txt',
  components: [
    {
      name: 'ejs',
      blob_path: null,
    },
    {
      name: 'saml2-js',
      blob_path: null,
    },
  ],
  ...changes,
});
