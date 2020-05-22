# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    project
    author(factory: :user) { project.creator }
    action { Event::JOINED }

    trait(:created)   { action { Event::CREATED } }
    trait(:updated)   { action { Event::UPDATED } }
    trait(:closed)    { action { Event::CLOSED } }
    trait(:reopened)  { action { Event::REOPENED } }
    trait(:pushed)    { action { Event::PUSHED } }
    trait(:commented) { action { Event::COMMENTED } }
    trait(:merged)    { action { Event::MERGED } }
    trait(:joined)    { action { Event::JOINED } }
    trait(:left)      { action { Event::LEFT } }
    trait(:destroyed) { action { Event::DESTROYED } }
    trait(:expired)   { action { Event::EXPIRED } }

    factory :closed_issue_event do
      action { Event::CLOSED }
      target factory: :closed_issue
    end

    factory :wiki_page_event do
      action { Event::CREATED }
      project { @overrides[:wiki_page]&.container || create(:project, :wiki_repo) }
      target { create(:wiki_page_meta, :for_wiki_page, wiki_page: wiki_page) }

      transient do
        wiki_page { create(:wiki_page, container: project) }
      end
    end

    trait :for_design do
      transient do
        design { create(:design, issue: create(:issue, project: project)) }
        note { create(:note, author: author, project: project, noteable: design) }
      end

      action { Event::COMMENTED }
      target { note }
    end
  end

  factory :push_event, class: 'PushEvent' do
    project factory: :project_empty_repo
    author(factory: :user) { project.creator }
    action { Event::PUSHED }
  end

  factory :push_event_payload do
    event
    commit_count { 1 }
    action { :pushed }
    ref_type { :branch }
    ref { 'master' }
    commit_to { '3cdce97ed87c91368561584e7358f4d46e3e173c' }
  end
end
