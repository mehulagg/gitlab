export function getMilestone({ milestone }) {
  return milestone || null;
}

export function fullEpicId(epicId) {
  return `gid://gitlab/Epic/${epicId}`;
}

export function fullMilestoneId(milestoneId) {
  return `gid://gitlab/Milestone/${milestoneId}`;
}

export function fullUserId(userId) {
  return `gid://gitlab/User/${userId}`;
}

export default {
  getMilestone,
  fullEpicId,
  fullMilestoneId,
  fullUserId,
};
