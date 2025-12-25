# Deploy & Backup Workflow

This document outlines the standard workflow for the `fil_web` project, ensuring distinct roles for Cloudflare and GitHub.

## 1. Cloudflare Pages: Deployment
-   **Role**: Hosting and public delivery of the website.
-   **Method**: All deployments are handled via `wrangler` CLI from the local environment.
-   **Command**:
    ```bash
    npm run build
    npx wrangler pages deploy dist --project-name fil-web
    ```
-   **Domain**: `filtokyo.com` (configured in Cloudflare Dashboard)

## 2. GitHub: Backup & Version Control
-   **Role**: Source code storage, version history, and backup.
-   **Remote**: `origin` -> `git@github.com:daitomanabe/FIL.git`
-   **Workflow**:
    1.  Make changes locally.
    2.  Commit changes: `git commit -am "Update message"`
    3.  Push to GitHub: `git push origin main`

## Summary of Operations
| Action | Platform | Command |
| :--- | :--- | :--- |
| **Publish Site** | Cloudflare | `npx wrangler pages deploy dist` |
| **Save Code** | GitHub | `git push origin main` |
