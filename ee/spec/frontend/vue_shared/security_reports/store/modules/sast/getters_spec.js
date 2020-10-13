import {
  SAST_HAS_ERROR,
  SAST_IS_LOADING,
} from 'ee/vue_shared/security_reports/store/modules/sast/constants';
import * as getters from 'ee/vue_shared/security_reports/store/modules/sast/getters';

const createReport = (config = {}) => ({
  paths: [],
  newIssues: [],
  ...config,
});

describe('groupedSastText', () => {
  it("should return the error message if there's an error", () => {
    const sast = createReport({ hasError: true });
    const result = getters.groupedSastText(sast);

    expect(result).toBe(SAST_HAS_ERROR);
  });

  it("should return the loading message if it's still loading", () => {
    const sast = createReport({ isLoading: true });
    const result = getters.groupedSastText(sast);

    expect(result).toBe(SAST_IS_LOADING);
  });

  it('should call groupedTextBuilder if everything is fine', () => {
    const sast = createReport();
    const result = getters.groupedSastText(sast);

    expect(result).toBe('SAST detected no vulnerabilities.');
  });
});

describe('sastStatusIcon', () => {
  it("should return `loading` when we're still loading", () => {
    const sast = createReport({ isLoading: true });
    const result = getters.sastStatusIcon(sast);

    expect(result).toBe('loading');
  });

  it("should return `warning` when there's an issue", () => {
    const sast = createReport({ hasError: true });
    const result = getters.sastStatusIcon(sast);

    expect(result).toBe('warning');
  });

  it('should return `success` when nothing is wrong', () => {
    const sast = createReport();
    const result = getters.sastStatusIcon(sast);

    expect(result).toBe('success');
  });
});
