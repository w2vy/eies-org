# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a containerized web application hosting project for EIES.org (Educational Interactive Electronic Systems). It consists of:
- A static HTML landing page served by Nginx
- A MediaWiki instance for collaborative documentation
- A MySQL database backend

## Commands

### Start all services
```bash
docker-compose up -d
```

### Stop all services
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f [service_name]
# service_name: wiki_db, wiki_app, eies.org_app
```

### Restart a specific service
```bash
docker-compose restart <service_name>
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose                            │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  eies.org_app   │  │    wiki_app     │  │   wiki_db   │ │
│  │  (Nginx Alpine) │  │  (MediaWiki)    │  │  (MySQL 8)  │ │
│  │  Port: 34370    │  │  Port: 34371    │  │  Internal   │ │
│  │                 │  │                 │  │             │ │
│  │  Serves:        │  │  Connects to →  │  │  Database:  │ │
│  │  eies.org/      │  │  wiki_db        │  │  mwnew      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Key files:**
- `docker-compose.yml` - Container orchestration
- `wiki/LocalSettings.php` - MediaWiki configuration (site: "WikiWorld")
- `db/mwnew.sql` - Database initialization script
- `eies.org/index.html` - Static landing page

**Persistent volumes:**
- `dbdata` - MySQL data
- `wikiimages` - MediaWiki uploaded images

## MediaWiki Configuration

The wiki is configured with:
- Public reading enabled, editing disabled for anonymous users
- Account creation disabled
- Vector 2022 as default skin
- Uploads disabled
