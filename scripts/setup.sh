#!/bin/bash
set -e

echo "🧠 LLM-Enhanced Threat Intelligence - Setup Script"
echo "===================================================="
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    exit 1
fi

echo "✅ Docker found"

# Check .env file
if [ ! -f .env ]; then
    echo ""
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.example .env
    echo "📝 Please edit .env with your API keys before continuing."
    echo "   Run: nano .env"
    echo ""
    echo "   Required keys:"
    echo "   - TELEGRAM_BOT_TOKEN"
    echo "   - PERPLEXITY_API_KEY"
    echo "   - OTX_API_KEY"
    echo "   - VIRUSTOTAL_API_KEY"
    echo "   - ABUSEIPDB_API_KEY"
    echo "   - HYBRID_ANALYSIS_API_KEY"
    echo ""
    read -p "Press Enter after you've edited .env to continue..."
else
    echo "✅ .env file found"
fi

# Start n8n
echo ""
echo "🚀 Starting n8n..."
docker-compose up -d

echo ""
echo "⏳ Waiting for n8n to start..."
sleep 10

# Check if n8n is running
if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "✅ n8n is running at http://localhost:5678"
else
    echo "⚠️  n8n might still be starting. Check with: docker-compose logs -f"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Open n8n at http://localhost:5678"
echo "2. Go to Workflows → Import from File"
echo "3. Select: n8n/workflows/threat-intel-workflow.json"
echo "4. Configure credentials (see README.md)"
echo "5. Activate the workflow"
echo "6. Send a test message to your Telegram bot!"
echo ""
echo "📖 Full setup guide: docs/SETUP_GUIDE.md"
