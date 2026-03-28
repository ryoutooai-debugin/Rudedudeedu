#!/bin/bash
# Auto-deploy script for samowl.net games
# Run manually or set up cron/ webhook

# FTP Credentials - UPDATE THESE
FTP_HOST="samowl.net"
FTP_USER="your_username"
FTP_PASS="your_password"
FTP_DIR="/games"

# Local file to deploy
DEPLOY_FILE="samowl-portfolio-challenge.html"

echo "🚀 Deploying $DEPLOY_FILE to samowl.net..."

# Upload via curl (FTP)
curl -T "$DEPLOY_FILE" -u "$FTP_USER:$FTP_PASS" "ftp://$FTP_HOST$FTP_DIR/$DEPLOY_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Deployed successfully!"
else
    echo "❌ Deploy failed!"
fi