/* eslint-disable no-new */

import mountComponents from 'ee/registrations/groups/new';
import GroupPathValidator from '~/pages/groups/new/group_path_validator';
import BindInOut from '~/behaviors/bind_in_out';
import Group from '~/group';

mountComponents();
new GroupPathValidator();
BindInOut.initAll();
new Group();
