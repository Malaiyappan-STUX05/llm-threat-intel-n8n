# 🧠 LLM-Enhanced Threat Intelligence Correlation Automation

> **Final Year B.Tech Project** — Malaiyappan S (RA2211030010001)  
> SRM Institute of Science and Technology, Cybersecurity

An **n8n-powered automated threat intelligence pipeline** that correlates vulnerability data from multiple sources (CISA KEV, AlienVault OTX, Perplexity AI, VirusTotal, AbuseIPDB, Hybrid Analysis) and delivers actionable threat reports via **Telegram**.

---

## 🎯 What It Does

Send a single Telegram message like:

```
analyze latest threat intel on Microsoft Exchange Server 2019
```

And get back a **comprehensive threat intelligence report** covering:

- ✅ **CVEs & Known Vulnerabilities** — from CISA KEV & AlienVault OTX
- ✅ **Threat Context & Analysis** — AI-summarized via Perplexity Sonar
- ✅ **IOC Extraction** — CVEs, IPs, domains, hashes from threat sources
- ✅ **IOC Enrichment** — VirusTotal, AbuseIPDB, Hybrid Analysis lookups
- ✅ **Risk Assessment** — Threat level scoring with recommendations
- ✅ **Formatted Telegram Report** — Clean, readable Markdown output

---

## 🏗️ Architecture

```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│   Telegram    │────▶│  Input Validation │────▶│  Perplexity AI      │
│   Trigger     │     │  (Parse product   │     │  (Threat Context)   │
│              │     │   & version)      │     └──────────┬──────────┘
└──────────────┘     └────────┬─────────┘                │
                              │                          ▼
                              │                 ┌─────────────────────┐
                              │                 │  IOC Extraction     │
                              │                 │  (Scrape citations, │
                              │                 │   extract CVEs,     │
                              │                 │   IPs, domains,     │
                              │                 │   hashes)           │
                              │                 └──────────┬──────────┘
                              │                          │
                              ▼                          ▼
                     ┌─────────────────┐      ┌─────────────────────┐
                     │  CISA KEV       │      │  IOC Enrichment     │
                     │  + OTX Search   │      │  ┌───────────────┐  │
                     │  (Vulnerability │      │  │ AbuseIPDB     │  │
                     │   Correlation)  │      │  │ VirusTotal    │  │
                     └────────┬────────┘      │  │ Hybrid Analysis│  │
                              │               │  └───────────────┘  │
                              │               └──────────┬──────────┘
                              │                          │
                              ▼                          ▼
                     ┌─────────────────────────────────────────┐
                     │         Correlation & Aggregation        │
                     │    (Merge all IOCs, group by source)     │
                     └────────────────────┬────────────────────┘
                                          │
                                          ▼
                     ┌─────────────────────────────────────────┐
                     │    LLM Report Generation (Perplexity)    │
                     │    (Summarize findings into report)      │
                     └────────────────────┬────────────────────┘
                                          │
                                          ▼
                     ┌─────────────────────────────────────────┐
                     │    Report Formatting & Telegram Reply     │
                     └─────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
llm-threat-intel-n8n/
├── README.md                          # This file
├── .env.example                       # Environment variable template
├── docker-compose.yml                 # n8n + dependencies setup
├── .gitignore                         # Git ignore rules
├── LICENSE                            # MIT License
├── docs/
│   ├── ARCHITECTURE.md                # Detailed architecture docs
│   ├── WORKFLOW_GUIDE.md              # Workflow explanation
│   └── SETUP_GUIDE.md                 # Detailed setup guide
├── n8n/
│   ├── workflows/
│   │   └── threat-intel-workflow.json # Main n8n workflow (import this)
│   └── credentials/
│       └── credentials-template.json  # Credential structure (no secrets)
└── scripts/
    ├── setup.sh                       # Quick setup script
    └── health-check.sh                # Verify all services are running
```

---

## 🚀 Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose
- [n8n](https://n8n.io/) (or use the included docker-compose)
- API keys for the services below

### Required API Keys

| Service | Purpose | Get Key |
|---------|---------|---------|
| **Telegram Bot** | Send/receive messages | [@BotFather](https://t.me/BotFather) |
| **Perplexity AI** | LLM threat analysis | [perplexity.ai/settings/api](https://www.perplexity.ai/settings/api) |
| **AlienVault OTX** | Threat intelligence pulses | [otx.alienvault.com](https://otx.alienvault.com/) |
| **VirusTotal** | IOC enrichment (IPs, domains, hashes) | [virustotal.com](https://www.virustotal.com/) |
| **AbuseIPDB** | IP reputation scoring | [abuseipdb.com](https://www.abuseipdb.com/) |
| **Hybrid Analysis** | Malware hash analysis | [hybrid-analysis.com](https://www.hybrid-analysis.com/) |

### Step-by-Step Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/llm-threat-intel-n8n.git
cd llm-threat-intel-n8n
```

#### 2. Configure Environment Variables

```bash
cp .env.example .env
# Edit .env with your API keys
nano .env
```

#### 3. Start n8n

```bash
docker-compose up -d
```

n8n will be available at `http://localhost:5678`

#### 4. Import the Workflow

1. Open n8n at `http://localhost:5678`
2. Go to **Workflows** → **Import from File**
3. Select `n8n/workflows/threat-intel-workflow.json`
4. The workflow will appear with all nodes connected

#### 5. Configure Credentials

In n8n, go to **Credentials** and add each service:

1. **Telegram API** — Your bot token from BotFather
2. **HTTP Header Auth** (Perplexity) — `Bearer YOUR_PPLX_KEY`
3. **HTTP Header Auth** (VirusTotal) — `x-apikey: YOUR_VT_KEY`
4. **HTTP Header Auth** (AbuseIPDB) — `Key: YOUR_ABUSEIPDB_KEY`
5. **HTTP Header Auth** (Hybrid Analysis) — `api-key: YOUR_HA_KEY`

> 💡 The OTX API key is embedded in the HTTP request headers within the workflow itself.

#### 6. Update Webhook URL

The Telegram trigger uses a webhook. After activating the workflow:
1. Copy the webhook URL from the Telegram Trigger node
2. Set it via Telegram Bot API:
   ```
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=<WEBHOOK_URL>
   ```

#### 7. Activate & Test

1. Click **Activate** on the workflow
2. Send a message to your Telegram bot:
   ```
   analyze latest threat intel on Microsoft Exchange Server 2019
   ```
3. Wait 30-60 seconds for the full pipeline to complete
4. Receive a detailed threat report in Telegram! 🎉

---

## 🔧 Configuration Options

### Input Format

The workflow expects messages in this exact format:

```
analyze latest threat intel on <product> <version>
```

**Examples:**
```
analyze latest threat intel on Apache Tomcat 9.0
analyze latest threat intel on Microsoft Exchange Server 2019
analyze latest threat intel on Nginx 1.24
analyze latest threat intel on WordPress 6.4
```

### Customizing Keywords

Edit the **Input validation** node's code to change search keywords:

```javascript
const keywords = ["CVE", "Vulnerability", "Exploit", "Threat", "Malware"];
// Add or remove keywords as needed
```

### Adjusting IOC Limits

- **OTX Search**: Change `limit=5` in the Loop OTX Search URL
- **Perplexity tokens**: Adjust `max_tokens` in the Pplx intel source body (default: 500)

---

## 📊 Data Flow

| Stage | Sources | Output |
|-------|---------|--------|
| **1. Input Parsing** | Telegram message | Product name, version, keywords |
| **2. Vulnerability Lookup** | CISA KEV, AlienVault OTX | Known CVEs for the product |
| **3. Threat Context** | Perplexity AI (Sonar) | Latest threat intel summary + citations |
| **4. IOC Extraction** | Citation URLs (web scrape) | CVEs, IPs, domains, file hashes |
| **5. IOC Enrichment** | VirusTotal, AbuseIPDB, Hybrid Analysis | Reputation scores, malware verdicts |
| **6. Correlation** | All sources merged | Grouped IOCs with multi-source context |
| **7. Report Generation** | Perplexity AI (Sonar) | Human-readable threat summary |
| **8. Delivery** | Telegram | Formatted Markdown report |

---

## 🛡️ Security Notes

- **Never commit `.env` files** — they contain API secrets
- **Rotate API keys** regularly
- **Rate limits**: Be aware of API rate limits on free tiers:
  - VirusTotal: 4 requests/min (free)
  - AbuseIPDB: 1000 requests/day (free)
  - Perplexity: Check your plan limits
- **Webhook security**: Use a strong webhook URL (n8n generates one automatically)

---

## 📝 Project Report

This project was submitted as the final year B.Tech project at SRM Institute of Science and Technology. The complete project report is available in the `docs/` directory.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Malaiyappan S** — B.Tech CSE (Cybersecurity), SRM Institute
