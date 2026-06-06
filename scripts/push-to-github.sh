#!/bin/bash
# Push this repository to GitHub
# Run this after creating a new empty repo on GitHub

GITHUB_USER="YOUR_GITHUB_USERNAME"
REPO_NAME="llm-threat-intel-n8n"

echo "Creating GitHub repository..."
echo "1. Go to https://github.com/new"
echo "2. Repository name: $REPO_NAME"
echo "3. Description: LLM-Enhanced Threat Intelligence Correlation Automation using n8n"
echo "4. Set to Public"
echo "5. Do NOT initialize with README (we have one)"
echo "6. Click 'Create repository'"
echo ""
read -p "Press Enter after creating the repo..."

# Initialize git
git init
git add -A
git commit -m "Initial commit: LLM-Enhanced Threat Intel Correlation Automation

- n8n workflow with 40 nodes for automated threat intelligence
- Multi-source correlation (CISA, OTX, Perplexity, VT, AbuseIPDB, HA)
- Telegram bot integration for on-demand reports
- Docker Compose setup
- Complete documentation and setup guides"

# Push
git branch -M main
git remote add origin "git@github.com:$GITHUB_USER/$REPO_NAME.git"
git push -u origin main

echo ""
echo "✅ Repository pushed to GitHub!"
echo "🌐 https://github.com/$GITHUB_USER/$REPO_NAME"
