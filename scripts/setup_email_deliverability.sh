#!/bin/bash
# Email Deliverability Setup Script
# Helps configure and test email system for reliable delivery

set -e

echo "=========================================="
echo "Email Deliverability Setup"
echo "=========================================="
echo ""

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    echo "ERROR: Composer is not installed."
    echo "Please install composer first: https://getcomposer.org/download/"
    exit 1
fi

echo "Step 1: Installing PHPMailer..."
cd "$(dirname "$0")/.."
composer require phpmailer/phpmailer:^6.9
echo "✓ PHPMailer installed successfully"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "Step 2: Creating .env file from .env.example..."
    cp .env.example .env
    echo "✓ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env file and configure SMTP settings!"
    echo ""
else
    echo "Step 2: .env file already exists"
    echo ""
fi

# Display current SMTP configuration
echo "Current SMTP Configuration:"
echo "-------------------------------------------"
if [ -f ".env" ]; then
    grep "^SMTP_" .env || echo "No SMTP settings found"
    grep "^FROM_EMAIL" .env || echo "No FROM_EMAIL found"
fi
echo "-------------------------------------------"
echo ""

# Test email configuration
echo "Step 3: Testing email configuration..."
php -r "
require_once 'includes/init.php';
require_once 'includes/RobustEmailService.php';

try {
    \$emailService = new RobustEmailService();
    echo 'Testing SMTP connection...' . PHP_EOL;
    
    if (\$emailService->testConnection()) {
        echo '✓ SMTP connection successful!' . PHP_EOL;
    } else {
        echo '✗ SMTP connection failed!' . PHP_EOL;
        echo 'Error: ' . \$emailService->getLastError() . PHP_EOL;
        echo '' . PHP_EOL;
        echo 'Please check your SMTP settings in .env file' . PHP_EOL;
        exit(1);
    }
} catch (Exception \$e) {
    echo '✗ Error: ' . \$e->getMessage() . PHP_EOL;
    exit(1);
}
"

if [ $? -eq 0 ]; then
    echo ""
    echo "Step 4: Setting up cron job for email queue processing..."
    echo ""
    echo "Add this line to your crontab (crontab -e):"
    echo "*/5 * * * * /usr/bin/php $(pwd)/process_email_queue.php >> /var/log/email_queue.log 2>&1"
    echo ""
    
    echo "=========================================="
    echo "Email Deliverability Setup Complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Configure SPF, DKIM, and DMARC DNS records"
    echo "2. Set up cron job for email queue processing"
    echo "3. Send test email to verify configuration"
    echo ""
    echo "See docs/EMAIL_DELIVERABILITY_GUIDE.md for detailed instructions"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "Setup encountered errors"
    echo "=========================================="
    echo ""
    echo "Please fix the errors above and run this script again."
    echo "See docs/EMAIL_DELIVERABILITY_GUIDE.md for help"
    echo ""
    exit 1
fi
