// Temporarily commented out to investigate performance: https://gitlab.com/gitlab-org/gitlab/-/issues/251179
// export * from '@sentry/browser';

export function captureException() {
  return false;
}
export function withScope() {
  return {
    setScope() {
      return false;
    }
  }
}
