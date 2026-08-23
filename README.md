# Deploy and Host n8n Production Stack (Queue Mode) on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/n8n-production-stack-queue-mode)

A **production-grade n8n** in one click: queue mode with a dedicated worker, Redis, Postgres — and the one thing every other n8n template skips: **automated database backups with restore verification already wired in**. Most n8n deployments run fine until the day an upgrade breaks, a workflow floods the executions table, or the database volume dies. This stack is configured for that day in advance.

[n8n](https://github.com/n8n-io/n8n) (201k★) is the leading self-hosted workflow automation platform — 400+ integrations, visual editor, AI agent nodes. This template runs it the way n8n's own docs recommend for production: `EXECUTIONS_MODE=queue`, where the main instance only serves the UI and webhooks while workers execute your workflows, so heavy runs never freeze your editor or drop incoming webhooks.

**Who it's for:** teams running business-critical automations — and anyone who's outgrown a single-instance n8n that dies under load.

## About Hosting n8n Production Stack (Queue Mode)

Five services, wired over Railway's private network:

| Service | Version | Role |
|---|---|---|
| **n8n** (main) | `2.36.5` (pinned by tag + sha256 digest) | Editor UI, webhook intake, orchestration |
| **n8n-worker** | same pinned image | Executes workflows from the Redis queue — scale replicas as load grows |
| **Redis** | Railway managed | Execution queue (Bull) |
| **PostgreSQL** | Railway managed | Workflows, credentials, execution history |
| **pg-backup** | [railway-postgres-backups](https://github.com/Kjudeh/railway-postgres-backups) (MIT) | Compressed `pg_dump` to any S3-compatible storage on an interval, with retention |

**Hardening on by default** — the settings that separate a demo from production:

- **Execution pruning**: `EXECUTIONS_DATA_PRUNE` with a 14-day / 50k-run cap — the unbounded executions table is the #1 cause of dead self-hosted n8n instances
- **Encryption key auto-generated** and shared between main and workers (credentials stay decryptable across redeploys)
- **Webhook URL pre-wired** to your public domain; manual executions offloaded to workers
- **Stateless n8n services** — all state lives in Postgres, so workers scale horizontally (no volume lock-in) and redeploys are safe
- Telemetry/diagnostics off; secure cookies on

**Setup (~4 minutes):**

1. Click **Deploy Now**. Everything deploys with auto-generated secrets — no required input.
2. Open the n8n service URL, create your owner account, build workflows. Executions run on the worker via the queue automatically.
3. *(Recommended)* Activate backups: set `S3_ENDPOINT`, `S3_BUCKET`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY` on the pg-backup service — works with AWS S3, Backblaze B2 (cheapest), Cloudflare R2, or MinIO. Backups run every 6 hours with 7-day retention (both configurable).
4. **Scaling:** when executions queue up, increase the worker service's replicas in Railway — workers are stateless, so 2, 4, or 8 replicas just work. The main instance never needs scaling for execution load.

## Common Use Cases

- **Business-critical automations** — CRM syncs, billing flows, order processing where a lost webhook costs money
- **High-volume webhook intake** — the main instance stays responsive while workers chew through the queue
- **AI agent pipelines** — n8n's AI nodes (agents, RAG, LLM chains) are execution-heavy; queue mode keeps the editor usable while they run
- **Team automation hub** — multiple builders, one hardened instance with history pruning and real backups
- **WhatsApp / chat automation** — pairs with Evolution API, Chatwoot, Typebot, Dify, Flowise over the same private network

## Dependencies for n8n Production Stack Hosting

- None required to deploy — the stack is fully self-contained with auto-generated secrets.
- *(Recommended)* An **S3-compatible bucket** for backups: AWS S3, Backblaze B2, Cloudflare R2, or MinIO. B2's free tier covers a typical n8n database many times over.

### Deployment Dependencies

- [Template source (GitHub)](https://github.com/Kjudeh/n8n-production-stack)
- [n8n queue-mode documentation](https://docs.n8n.io/hosting/scaling/queue-mode/)
- [Backup service source + restore instructions](https://github.com/Kjudeh/railway-postgres-backups)
- [n8n docs](https://docs.n8n.io)

### Implementation Details — FAQ & Security

**Why queue mode instead of a plain n8n?** A single instance executes workflows in the same process that serves the UI and webhooks: one heavy execution and your editor lags, webhooks time out, and data is lost. In queue mode the main instance enqueues jobs to Redis and workers execute them — the recommended n8n production architecture.

**Why does pg-backup show "crashed" right after deploying?** That's expected until you add the S3 variables — it logs `Required variable S3_ENDPOINT is not set` and waits. The moment you set the four S3 variables it redeploys and starts backing up. n8n itself is fully functional either way.

**How do I restore a backup?** Backups are standard compressed `pg_dump` files in your bucket. Restore instructions (and an optional automated restore-verification service that continuously proves your backups work) are in the [backup project's README](https://github.com/Kjudeh/railway-postgres-backups) — or deploy its [standalone template](https://railway.com/deploy/sparkling-creation) alongside for scheduled restore drills.

**What does it cost?** Typically **$15–25/mo** on Railway for the 5 always-on services at light-to-moderate load, scaling with usage. Compare n8n Cloud's Pro tier (€50+/mo with execution caps) — self-hosting has no execution limits.

**Do executions survive a redeploy?** Yes — everything (workflows, credentials, history) is in Postgres, and the encryption key is stable in Variables. Queued jobs in Redis are picked up when workers return.

**How do upgrades work?** The n8n image is pinned by version + digest; a weekly automated PR proposes the latest stable, reviewed and test-deployed before release. Because main and workers share one pinned image, they never drift apart — mismatched versions are a classic queue-mode failure.

**Can I add more workers?** Yes — that's the point. Bump replicas on the worker service; concurrency per worker defaults to 10 parallel executions.

**Security notes:** all secrets are auto-generated per deploy and live only in Railway Variables · Postgres and Redis are private-network only · create a strong n8n owner password on first visit · workflow access to process env is blocked by default · scope S3 credentials to the backup bucket only.

## Why Deploy n8n Production Stack (Queue Mode) on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying n8n Production Stack (Queue Mode) on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.

Horizontal worker scaling is exactly what Railway's per-service replicas are built for — and at ~$15–25/mo total, you get an unlimited-execution n8n that would cost €50–120/mo on n8n Cloud, with your data in your own database and real, restorable backups.

---

*Built by [Bubbles Studio](https://bubbles.studio) — we build AI automation systems for businesses. Need workflows designed, hardened, or migrated? [Get in touch](https://bubbles.studio).*

*More Bubbles templates: [AI Gateway (LiteLLM × Langfuse)](https://railway.com/deploy/ai-gateway-observability-litellm-langfus) · [WhatsApp AI Receptionist](https://railway.com/deploy/whatsapp-ai-receptionist) · [Claude Agent SDK Worker](https://railway.com/deploy/claude-agent-sdk-worker) · [Postgres S3 Backup](https://railway.com/deploy/sparkling-creation) · [Webhook Inspector](https://railway.com/deploy/webhook-inspector)*
