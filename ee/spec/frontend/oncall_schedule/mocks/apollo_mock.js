export const participants = [
  {
    id: '1',
    username: 'test',
    name: 'test',
    avatar: '',
    avatarUrl: '',
  },
  {
    id: '2',
    username: 'hello',
    name: 'hello',
    avatar: '',
    avatarUrl: '',
  },
];
export const errorMsg = 'Something went wrong';

export const getOncallSchedulesQueryResponse = {
  data: {
    project: {
      incidentManagementOncallSchedules: {
        nodes: [
          {
            __typename: 'IncidentManagementOncallSchedule',
            iid: '37',
            name: 'Test schedule',
            description: 'Description 1 lives here',
            timezone: {
              identifier: 'Pacific/Honolulu',
            },
          },
        ],
      },
    },
  },
};

export const destroyScheduleResponse = {
  data: {
    oncallScheduleDestroy: {
      errors: [],
      oncallSchedule: {
        __typename: 'IncidentManagementOncallSchedule',
        iid: '37',
        name: 'Test schedule',
        description: 'Description 1 lives here',
        timezone: 'Pacific/Honolulu',
      },
    },
  },
};

export const destroyScheduleResponseWithErrors = {
  data: {
    oncallScheduleDestroy: {
      errors: ['Houston, we have a problem'],
      oncallSchedule: {
        __typename: 'IncidentManagementOncallSchedule',
        iid: '37',
        name: 'Test schedule',
        description: 'Description 1 lives here',
        timezone: 'Pacific/Honolulu',
      },
    },
  },
};

export const updateScheduleResponse = {
  data: {
    oncallScheduleDestroy: {
      errors: [],
      oncallSchedule: {
        __typename: 'IncidentManagementOncallSchedule',
        iid: '37',
        name: 'Test schedule 2',
        description: 'Description 2 lives here',
        timezone: 'Pacific/Honolulu',
      },
    },
  },
};

export const preExistingSchedule = {
  description: 'description',
  iid: '1',
  name: 'Monitor rotations',
  timezone: 'Pacific/Honolulu',
};

export const newlyCreatedSchedule = {
  description: 'description',
  iid: '2',
  name: 'S-Monitor rotations',
  timezone: 'Kyiv/EST',
};
