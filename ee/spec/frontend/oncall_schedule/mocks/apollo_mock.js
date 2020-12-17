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
    oncallScheduleUpdate: {
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

export const updateScheduleResponseWithErrors = {
  data: {
    oncallScheduleUpdate: {
      errors: ['Houston, we have a problem'],
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

export const createRotationResponse = {
  data: {
    oncallRotationCreate: {
      errors: [],
      oncallRotation: {
        id: '37',
        name: 'Test',
        startsAt: '2020-12-17T12:00:00Z',
        length: 5,
        lengthUnit: 'WEEKS',
        participants: {
          nodes: [
            {
              user: { id: 'gid://gitlab/User/50', username: 'project_1_bot3', __typename: 'User' },
              colorWeight: '500',
              colorPalette: 'blue',
              __typename: 'OncallParticipantType',
            },
          ],
          __typename: 'OncallParticipantTypeConnection',
        },
        __typename: 'IncidentManagementOncallRotation',
      },
      __typename: 'OncallRotationCreatePayload',
    },
  },
};

export const createRotationResponseWithErrors = {
  data: {
    oncallRotationCreate: {
      errors: ['Houston, we have a problem'],
      oncallRotation: {
        id: '37',
        name: 'Test',
        startsAt: '2020-12-17T12:00:00Z',
        length: 5,
        lengthUnit: 'WEEKS',
        participants: {
          nodes: [
            {
              user: { id: 'gid://gitlab/User/50', username: 'project_1_bot3', __typename: 'User' },
              colorWeight: '500',
              colorPalette: 'blue',
              __typename: 'OncallParticipantType',
            },
          ],
          __typename: 'OncallParticipantTypeConnection',
        },
        __typename: 'IncidentManagementOncallRotation',
      },
      __typename: 'OncallRotationCreatePayload',
    },
  },
};
