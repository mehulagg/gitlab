import { redirectUserWithSSOIdentity } from 'ee/saml_sso';

describe('redirectUserWithSSOIdentity', () => {
  describe('when auto redirect link exists', () => {
    let link;

    beforeEach(() => {
      link = document.createElement('a');
      link.setAttribute('id', 'js-auto-redirect-to-provider');
      link.setAttribute('href', 'https://foobar.com/sso-service');
      link.click = jest.fn();

      document.body.appendChild(link);
    });

    afterEach(() => {
      document.body.innerHTML = '';
    });

    it('clicks the link', () => {
      redirectUserWithSSOIdentity();

      expect(link.click).toHaveBeenCalled();
    });
  });

  describe('when auto redirect link does not exist', () => {
    it('does nothing', () => {
      expect(redirectUserWithSSOIdentity()).toBeUndefined();
    });
  });
});
