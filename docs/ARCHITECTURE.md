# Architecture Documentation

## System Overview

The LLM-Enhanced Threat Intelligence Correlation Automation is a multi-stage pipeline built on n8n that automates the collection, enrichment, and reporting of cybersecurity threat intelligence.

## Pipeline Stages

### Stage 1: Input Parsing
- **Node**: Telegram Trigger → Input Validation (Code)
- **Input**: Natural language Telegram message
- **Logic**: Regex extraction of product name and version
- **Output**: Structured `{ product, version, keywords }` object
- **Default Keywords**: `["CVE", "Vulnerability", "Exploit", "Threat", "Malware"]`

### Stage 2: Vulnerability Correlation (Parallel)
#### Path A — CISA Known Exploited Vulnerabilities (KEV)
- Fetches the CISA KEV JSON feed
- Filters by product name and version match on `vendor_product`
- Outputs matching CVE entries

#### Path B — AlienVault OTX
- Searches OTX pulses using product + version + keywords
- Loops through each keyword for broader coverage
- Returns up to 5 results per keyword

### Stage 3: AI-Powered Threat Context
- **Service**: Perplexity AI (Sonar model)
- **Prompt**: "Provide latest English threat intel for {product} {version} covering CVE, Vulnerability, Exploit, Threat, Malware, IOCs"
- **Output**: Threat summary + citation URLs + search results

### Stage 4: IOC Extraction
- Loops through Perplexity's citation URLs
- Fetches each page with browser-like headers
- Extracts using regex:
  - **CVEs**: `CVE-YYYY-NNNNN` pattern
  - **IPs**: IPv4 addresses (filtered for public IPs only)
  - **Domains**: Valid domain names with known TLDs
  - **Hashes**: MD5 (32), SHA1 (40), SHA256 (64 hex chars)
- Handles blocked pages (403, Cloudflare) gracefully

### Stage 5: IOC Enrichment (Parallel by Type)
#### IP Addresses → AbuseIPDB
- Checks IP reputation score, country, reports
- Filters: Only valid public IPv4 (excludes private, loopback, link-local)

#### Domains → VirusTotal DNS
- Checks domain reputation and analysis stats
- Filters: Valid domains with known TLDs

#### Hashes → VirusTotal Files + Hybrid Analysis
- VT: File reputation and detection stats
- HA: Sandbox verdicts and report counts

### Stage 6: Correlation & Aggregation
- Merges all enrichment results from 5 inputs
- Flattens loop outputs across iterations
- Groups by IOC with source-based enrichment
- Creates a structured summary for LLM consumption

### Stage 7: Report Generation
- **Service**: Perplexity AI (Sonar model)
- **Input**: All correlated IOC data + product context
- **Output**: Human-readable threat intelligence summary

### Stage 8: Report Formatting & Delivery
- Cleans Markdown (removes bold, headers, emojis)
- Converts tables to bullet points
- Adds section spacing and threat level indicator
- Truncates to 4000 chars (Telegram limit)
- Sends formatted report back to Telegram

## Error Handling
- Blocked pages (403, Cloudflare) → Skipped with reason
- Invalid IPs → Filtered before API calls
- Invalid domains → Filtered before API calls
- Empty hash values → Skipped before API calls
- HTTP errors → `continueRegularOutput` (doesn't break pipeline)
- Retry logic on Perplexity API calls

## Data Flow Diagram

```
Telegram Message
    │
    ▼
┌─────────────────────┐
│ Input Validation     │──→ product, version, keywords
└─────────┬───────────┘
          │
    ┌─────┴─────┐
    ▼           ▼
┌────────┐  ┌──────────────┐
│ CISA   │  │ Perplexity   │
│ KEV    │  │ AI (Context) │
└───┬────┘  └──────┬───────┘
    │              │
    │         ┌────┴────┐
    │         ▼         ▼
    │    ┌────────┐ ┌────────┐
    │    │  OTX   │ │Citation│
    │    │ Search │ │ URLs   │
    │    └────────┘ └────┬───┘
    │                    │
    │              ┌─────┴─────┐
    │              ▼           ▼
    │        ┌──────────┐ ┌────────┐
    │        │   Web    │ │  IOC   │
    │        │ Scraping │ │Extract │
    │        └──────────┘ └───┬────┘
    │                         │
    │                    ┌────┴────┐
    │                    ▼         ▼
    │              ┌────────┐ ┌────────┐
    │              │Enrich  │ │Enrich  │
    │              │(VT,    │ │(Abuse, │
    │              │ HA)    │ │ VT)    │
    │              └────────┘ └────────┘
    │                    │
    └────────┬───────────┘
             ▼
    ┌─────────────────┐
    │  Correlation &   │
    │  Aggregation     │
    └────────┬────────┘
             ▼
    ┌─────────────────┐
    │ LLM Report      │
    │ Generation      │
    └────────┬────────┘
             ▼
    ┌─────────────────┐
    │ Format & Send   │
    │ to Telegram     │
    └─────────────────┘
```
