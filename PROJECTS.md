# Projects Registry

All projects managed by this Ralph instance.

| Name | Path | Template | Created | Status | Related | Description |
|------|------|----------|---------|--------|---------|-------------|
| personal-finance-manager | ../personal-finance-manager | general | 2026-05-03 | active | — | Personal Finance & Asset Strategy 2026 |
| life-schedule-ai | ../life-schedule-ai | harness-scaffold | 2026-05-01 | active | — | AI manager for daily schedule, reservations, and sleep patterns |
| certification-scheduler | ../certification-scheduler | harness-scaffold | 2026-05-01 | active | — | Automated schedule checker and calendar sync for certification exams |
| publishing-manager | ../publishing-manager | general | 2026-05-01 | active | — | Track and manage book publishing tasks |
| career-tracker | ../career-tracker | general | 2026-05-01 | active | — | Data Engineer/Scientist career path planning for Japan/Canada |
| personal-data-agent | ../personal-data-agent | harness-scaffold | 2026-05-01 | active | — | Personal data management agent with data processing, scraping, and telegram integration |
| llm-wiki | ../llm-wiki | general | 2026-05-01 | active | — | Knowledge repository based on LLM Wiki pattern |
| reminders-manager | ../reminders-manager | harness-scaffold | 2026-05-01 | active | — | Apple Reminders CRUD and schedule management app |
| hub-credentials | ../hub-credentials | general | 2026-05-01 | active | — | Personal credentials and Gmail reader management |

## How to Add a Project

```bash
# Development project (uses harness-scaffold template)
./scripts/new-project.sh my-app dev "My SaaS application"

# General project (minimal template for non-dev work)
./scripts/new-project.sh marketing general "Q3 marketing plan"

# Import an existing sibling repository
./scripts/import-project.sh existing-api harness-scaffold "Imported API repo"
```

Paths are stored relative to `ralph/`, so sibling repositories usually appear as `../project-name`.
