export const projectPath = '';
export const timezones = ['PST'];
export const ID = '7';
export const errorMsg = 'Something went wrong';

export const getOncallSchedulesQueryResponse = {
  data: {
    project: {
      incidentManagementOncallSchedules: {
        nodes: [
          {
            iid: '37',
            name: 'Test schedule',
            description: 'Description 1 lives here',
            timezone: 'Europe/Dublin',
          },
        ],
      },
    },
  },
};

export const scheduleToDestroy = {
  iid: '37',
  name: 'Test schedule',
  description: 'Description 1 lives here',
  timezone: 'Europe/Dublin',
};

export const destroyScheduleResponse = {
  data: {
    oncallScheduleDestroy: {
      errors: [],
      oncallSchedule: {
        iid: '37',
        name: 'Test schedule',
        description: 'Description 1 lives here',
        timezone: 'Europe/Dublin',
      },
    },
  },
};

export const destroyScheduleResponseWithErrors = {
  data: {
    oncallScheduleDestroy: {
      errors: ['Houston, we have a problem'],
      oncallSchedule: {
        iid: '37',
        name: 'Test schedule',
        description: 'Description 1 lives here',
        timezone: 'Europe/Dublin',
      },
    },
  },
};
