# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a containerized web application hosting project deployed on Flux (runonflux.io). It consists of:
- Two static HTML landing pages served by Nginx (eies.org, whitescarver.com)
- A MediaWiki instance (wikiworld.com) served by Apache
- A MySQL database backend

All services run in a single Docker container using supervisord.

## Commands

### Build
```bash
docker build -t eies-org .
```

### Run locally
```bash
docker run -p 34370:80 -p 34371:8080 -p 34372:81 eies-org
```

### Debug inside container
```bash
docker exec -it <container_id> bash
```

## Port Layout

| External (Flux) | Internal | Site |
|-----------------|----------|------|
| 34370 | 80 | eies.org (nginx) |
| 34371 | 8080 | www.wikiworld.com (Apache/MediaWiki) |
| 34372 | 81 | whitescarver.com (nginx) |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Single Docker Container (supervisord)          │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Nginx     │  │   Apache    │  │       MySQL         │ │
│  │  :80, :81   │  │   :8080     │  │     (internal)      │ │
│  │             │  │             │  │                     │ │
│  │ eies.org    │  │ MediaWiki   │  │  Database: mwnew    │ │
│  │ whitescarver│  │ wikiworld   │  │  User: mediawiki    │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Key Files

- `Dockerfile` - All-in-one container build
- `docker-entrypoint.sh` - Database initialization and config generation
- `supervisord.conf` - Process management (mysql, apache, nginx)
- `nginx-landing.conf` - Nginx virtual host configuration
- `wiki/LocalSettings.php` - MediaWiki configuration template
- `db/mwnew.sql` - Database initialization script

## MediaWiki Configuration

- Site name: "WikiWorld"
- Public reading enabled, editing disabled for anonymous users
- Account creation disabled
- Vector 2022 as default skin
- Uploads disabled
