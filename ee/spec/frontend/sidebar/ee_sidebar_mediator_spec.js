import SidebarMediator from 'ee/sidebar/sidebar_mediator';
import SidebarService from '~/sidebar/services/sidebar_service';
import CESidebarMediator from '~/sidebar/sidebar_mediator';
import CESidebarStore from '~/sidebar/stores/sidebar_store';
import Mock from './ee_mock_data';

describe('EE Sidebar mediator', () => {
  let mediator;

  beforeEach(() => {
    mediator = new SidebarMediator(Mock.mediator);
  });

  afterEach(() => {
    SidebarService.singleton = null;
    CESidebarStore.singleton = null;
    CESidebarMediator.singleton = null;
  });

  it('processes fetched data', () => {
    const mockData =
      Mock.responseMap.GET['/gitlab-org/gitlab-shell/issues/5.json?serializer=sidebar'];
    const mockGraphQlData = Mock.graphQlResponseData;
    mediator.processFetchedData(mockData, mockGraphQlData);

    expect(mediator.store.weight).toBe(mockData.weight);
    expect(mediator.store.status).toBe(mockGraphQlData.project.issue.healthStatus);
  });
});
