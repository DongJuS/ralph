# Ralph

Project factory — 무한히 새 프로젝트를 생성하고 관리하는 레포.

## 구조

- **ralph** (이 레포) — 프로젝트 생성/관리 도구
- **[harness-scaffold](https://github.com/DongJuS/harness-scaffold)** — 개발 프로젝트 템플릿 (별도 레포)

Ralph는 harness-scaffold를 clone해서 새 개발 프로젝트를 만들거나, 최소 템플릿으로 비개발 프로젝트를 만듭니다.

## Quick Start

```bash
# 개발 프로젝트 생성 (harness-scaffold 템플릿)
./scripts/new-project.sh my-saas-app dev "SaaS 애플리케이션"

# 비개발 프로젝트 생성 (최소 템플릿)
./scripts/new-project.sh q3-marketing general "Q3 마케팅 계획"

# 프로젝트 목록 확인
./scripts/list-projects.sh

# 프로젝트 제거 (목록에서만)
./scripts/remove-project.sh old-project

# 프로젝트 제거 (디렉토리까지)
./scripts/remove-project.sh old-project --delete
```

## 프로젝트 타입

### dev (개발 프로젝트)

harness-scaffold 전체 구조를 clone합니다:
- 200줄 제한 + INDEX.md 네비게이션
- ADR / 일지 / 고민 기록 3종 로그
- 모순 방지 (AUTHORITY.md, supersede chain, 충돌 감지)
- 8개 역할 프로필 + 자동 매핑 + 리뷰 게이트
- 멀티세션 조율 + 핸드오프
- 코드 검증 게이트 + 대시보드
- Ralph Loop 통합

### general (비개발 프로젝트)

최소 구조만 생성합니다:
- README.md, CLAUDE.md
- docs/ (decisions/, journals/)
- 200줄 제한 + 자기완결 작성 기준

## 버전 관리

모든 변경사항은 GitHub push로 관리합니다.

```bash
git add -A && git commit -m "feat: description" && git push
```

## Prerequisites

- git
- jq (`brew install jq` on macOS)
- Claude Code (optional, for Ralph Loop)
