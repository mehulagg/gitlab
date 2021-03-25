---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Frontend Maintainer Values

You can find more about the organization of the frontend team in the [handbook](https://about.gitlab.com/handbook/engineering/frontend/).

## Why

At GitLab, we have a large selection of Front-end maintainers who strive for the highest quality when reviewing merge requests. However, due to the nature of being human, we are often subject to individual nuances that may or may not serve the overall codebase of GitLab well. 

This was raised as a discussion point in the [Frontend maintainer meeting by @sarahghp](https://docs.google.com/document/d/1RPdpyoJrBsRkwi7LWDpJfLuDnMnbn8nzrLOdVObBdfM/edit#heading=h.mtuikdpz09jx) as to `What is the ideal balance between code consistency team-to-team? Are we trying to pick too many nits in pursuit of consistency?` which evolved into a larger question of:

> As a maintainer, what values should we choose to enforce in reviews, and what can be considered with more flux? Following this, with items granted more flux, how do we approach that? Do we aim for a collaborative model and encourage maintainers to share branches with authors / encourage more follow-up issues / follow-up merges, or what can be ignored as a personal preference?

Or in a more simple expression:

> When does a merge warrant being blocked when evaluated against our values? And if it does, would your peer maintainers agree with this judgment?

Given these question, we on the Frontend set out to create a set of specific values that would help to drive the maintainer process during reviews.

## Table Of Contents

- [Tradeoffs => Collaboration](#tradeoffs----collaboration)
- [Velocity => Iteration](#velocity----iteration)
- [Quality = Results](#quality---results)
- [Honestly => Transparency](#honestly----transparency)
- [Making Space => Diversity](#making-space----diversity)

### Tradeoffs => Collaboration

> There are no solutions only trade offs - Thomas Sowell

In software, there are simply no perfect solutions. They do not exist. The reason for this is because we as human beings are generally pretty bad at deep, layered, abstract logic which is exactly what software is. Your code might be really easy to understand but not very useful. Your code might be extremely useful but expensive to run. Your software might be both useful and cheap to run but extremely difficult to read. 

Step 1 of being a great Frontend maintainer is learning to accept, manage and communicate what are acceptable tradeoffs in the GitLab Frontend codebase. 

#### How to identify trade offs?

Generally, each maintainer will have their own guiding light for what they consider to be a valid trade off in terms of code quality against feature development but some great places to start with the frontend are:

1. High level consistency => Does this code look (mostly) like the rest of our code base? 
1. State Management => Do we need the state thats being added or can we aim to reduce the amount of state involved?
1. Testing => Are the specs provided (specs should almost always be provided for any given merge) cover the features use case and the component contracts? 
1. Dependencies => Does this code introduce N+ dependencies? These can be in the form of external or internal dependencies and should be a question point as every-time a dependencies is leaned on it becomes something to support.
1. Maintainability/Readability => In order to deduce these tradeoffs, very simply ask yourself if a junior developer could hump into the codebase following this merge and pick up where the code is now at. 
1. Fragility => Does the code in this merge introduce fragility into the codebase?

As a maintainer, what we want to strive for is the **overall** maintainability of the GitLab Frontend code base. This should be the starting point for every code review when establishing tradeoffs. Each maintainer is afforded a measure of leeway with their own style as this is what makes them a maintainer, they have their own expertise to apply but in general you can see the value here is not about a personal opinion nor style, but a overall commitment to not making the codebase worse through poor tradeoffs. 

#### How to communicate trade offs?

When you are reviewing a merge and identify a tradeoff, you should aim to communicate the tradeoff you've seen, why you believe its a tradeoff and then aim to work towards a solution with the merge author. This will help to foster a bias for action and collaboration. Approach this with kindness in a merge in your communication, the author may not realise they have introduced a difficult choice for the maintainer as they just wanted to write good code (hopefully) to solve their problem, often authors will not think of the far reaching effects of their choices (nor should they, this will lead to a lack of progress). 

### Velocity => Iteration / Bias for action

At GitLab, we like to iterate and this should be a core value of how you judge a merge requests validity. We value iteration in GitLab because we value breaking problems down into their smallest piece possible and because it calls for a bias for action. If we truly believe in this as a guiding principal it should make your job as a maintainer easier since the context for you to review should be small and digestible. This is something you as a maintainer should be constantly encouraging in authors; "Can we make this smaller?" should be a very common question you ask yourself when looking to review code. 

### Quality => Results

This was touched on above in the trade offs section but it bears repeating. Being a maintainer is a tough juggling act as you will find yourself balancing iteration vs quality concerns a lot of the time but a bias for quality will serve you(and the rest of the codebase!) well here. The easiest way to express this ao an author would be that if a merge was broken down to a good degree it would cover both iteration and quality as each merge would represent a very small, simple and boring solution. 

This approach also helps to teach authors how to think out the solution to a large / complex problem by ensuring its broken into small, quality driven pieces. 

Some practical examples of quality to watch for as a maintainer:

- Is the code readable / easily understood?
- Does it solve a single issue at a time?
- Is it fragile or easily extended / modified?
- Are there supporting specs a correct representation of the I/O of the components? 

### Honesty => Transparency / Communication

Being honest is hard, it's made harder when there is a perceived imbalance in authority between the merge author and the merge reviewer. As an author, it can be tempting to be misleading to get your code pushed through if asked hard or blocking questions. As a maintainer, it can be tempting to skip over admitting you don't understand something. 

What we need to do as a maintainer is maintain a sense of honesty above all else when approaching a review. If you do not understand something, let it be known and ask (either ask the author or consult another maintainer as a collaboration / learning exercise)! The same rings true for if you disagree with an approach the author has taken, this is okay to voice but as a maintainer the burden falls onto you to be sure you disagree because of a core flaw with the approach and its not a personal preference issue.

Pro-tip: When in doubt ask another maintainer for a sanity check.

### Making Space => Diversity

At GitLab, we aim to be as inclusive as possible and this includes making space for people to grow and learn in their own way. As a maintainer, you should look to encourage authors to ask questions, make mistakes and be fearless with their attempts to make something awesome. While we want the highest quality of code at GitLab, we also need to leave space for compassion which creates the safety net authors deserve when they hit that submit button and ask for a review. 

If you find yourself working with a merge request that is not going to meet the quality bench mark, aim to let the author absorb that as a learning experience but help to foster the right response of being inspired to try again with another, better merge, not fear of being seeing as lacking in someway. 

### Nitpicks => A special mention

> Perfectionism is toxic

Nitpicks are born from a wonderful place for most reviewers of wanting to ensure they provide the most end-to-end review possible and highlight every single potential issue. This generally translates into two types of comments:

- Show stoppers 
- Nitpicks 

While showstoppers and important to voice as a maintainer(even if it initially born from a personal preference), but smaller non-blocking nitpicks have the issue that they create a lot of noise - useful feedback in a code review which can at best bog down a review, or at worst create a toxic merge for the author. 

While Paul Slaughter has a wonderful method for helping to inject context into your comments via [conventionalcomments](https://conventionalcomments.org/), it's always worth sanity checking yourself if you have a lot of nitpicks to offer in a review and if they will really make a positive difference for the author. 

If you want to see more reasons for this you should check out [stop nitpicking](https://blog.danlew.net/2021/02/23/stop-nitpicking-in-code-reviews/)
## TL;DR

- Stick to the high-level stuff where you can. Nitty gritty is often not useful. 
- Encourage but don't demand boring, simple solutions. 
- Consult yur fellow maintainer often.
- Everything is a tradeoff, consider the far reaching impact and if this code makes the overall codebase better or worse. 
- Watch your dependencies. 
- Admit when you don't know something.
- Be kind and look to teach where possible.
- Lean towards a bias for action and collaboration(don't be afraid to fix linting errors for authors if the rest of teh merge is LGTM!).
- Create space for people to fail, make mistakes and try crazy things. 
