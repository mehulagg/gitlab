/* eslint-disable no-new */

import mountProgressBar from 'ee/subscriptions/groups/edit';
import BindInOut from '~/behaviors/bind_in_out';
import Group from '~/group';
import GroupPathValidator from '~/pages/groups/new/group_path_validator';

mountProgressBar();
new GroupPathValidator();
BindInOut.initAll();
new Group();
