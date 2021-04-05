import initTabs from 'ee/analytics/devops_report/tabs';
import Api from '~/api';

jest.mock('~/api.js');
jest.mock('~/lib/utils/common_utils');

describe('tabs', () => {
  beforeEach(() => {
    setFixtures(`
    <div>
      <div class="js-devops-tab-item">
        <a href="#devops-score" data-testid='score-tab'>Score</a>
      </div>
      <div class="js-devops-tab-item">
        <a href="#devops-adoption" data-testid='devops-adoption-tab'>Adoption</a>
      </div>
    </div`);

    initTabs();
  });

  afterEach(() => {});

  describe('tracking', () => {
    it('tracks event when adoption tab is clicked', () => {
      document.querySelector('[data-testid="devops-adoption-tab"]').click();

      expect(Api.trackRedisHllUserEvent).toHaveBeenCalledWith('i_analytics_dev_ops_adoption');
    });

    it('does not track an event when score tab is clicked', () => {
      document.querySelector('[data-testid="score-tab"]').click();

      expect(Api.trackRedisHllUserEvent).not.toHaveBeenCalled();
    });
  });
});
