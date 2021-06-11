import { returnToPreviousPageFactory } from 'ee/security_configuration/dast_profiles/redirect';
import { TEST_HOST } from 'helpers/test_constants';
import * as urlUtility from '~/lib/utils/url_utility';

const fullPath = 'group/project';
const profilesLibraryPath = `${TEST_HOST}/${fullPath}/-/security/configuration/dast_scans`;
const onDemandScansPath = `${TEST_HOST}/${fullPath}/-/on_demand_scans`;
const dastConfigPath = `${TEST_HOST}/${fullPath}/-/security/configuration/dast`;
const urlParamKey = 'site_profile_id';
const originalReferrer = document.referrer;

const params = {
  allowedPaths: [onDemandScansPath, dastConfigPath],
  profilesLibraryPath,
  urlParamKey,
};

const factory = (id) => returnToPreviousPageFactory(params)(id);

const setReferrer = (value = onDemandScansPath) => {
  Object.defineProperty(document, 'referrer', {
    value,
    configurable: true,
  });
};

const resetReferrer = () => {
  setReferrer(originalReferrer);
};

describe('DAST Profiles redirector', () => {
  describe('returnToPreviousPageFactory', () => {
    beforeEach(() => {
      jest.spyOn(urlUtility, 'redirectTo').mockImplementation();
    });

    it('default - redirects to profile library page', () => {
      factory();
      expect(urlUtility.redirectTo).toHaveBeenCalledWith(profilesLibraryPath);
    });

    describe.each([
      ['On-demand scans', onDemandScansPath],
      ['DAST Configuration', dastConfigPath],
    ])('when previous page is %s', (_pathName, path) => {
      beforeEach(() => {
        setReferrer(path);
      });

      afterEach(() => {
        resetReferrer();
      });

      it('redirects to previous page', () => {
        factory();
        expect(urlUtility.redirectTo).toHaveBeenCalledWith(path);
      });

      it('redirects to previous page with id', () => {
        factory({ id: 2 });
        expect(urlUtility.redirectTo).toHaveBeenCalledWith(`${path}?site_profile_id=2`);
      });
    });
  });
});
