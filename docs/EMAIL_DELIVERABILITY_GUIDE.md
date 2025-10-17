# Email Deliverability Setup Guide

## Overview

This guide ensures all emails and notifications are delivered reliably without issues. The system uses PHPMailer with proper SMTP configuration, email validation, retry logic, and deliverability best practices.

## Quick Fix Implementation

### 1. Install PHPMailer

```bash
composer install
# or
composer require phpmailer/phpmailer:^6.9
```

### 2. Configure SMTP in .env

```env
# Email Settings
SMTP_HOST=smtp.your-provider.com
SMTP_PORT=587
SMTP_USERNAME=no-reply@yourdomain.com
SMTP_PASSWORD=your-smtp-password
SMTP_ENCRYPTION=tls
FROM_EMAIL=no-reply@yourdomain.com
FROM_NAME="Your App Name"
SUPPORT_EMAIL=support@yourdomain.com
```

### 3. Setup Email Queue Processing

Add to crontab:
```bash
# Process email queue every 5 minutes
*/5 * * * * /usr/bin/php /path/to/process_email_queue.php >> /var/log/email_queue.log 2>&1
```

## Email Deliverability Best Practices

### 1. SPF Record (Required)

Add SPF record to your DNS:

```
Type: TXT
Name: @
Value: v=spf1 include:_spf.your-smtp-provider.com ~all
```

For common providers:
- **SendGrid**: `v=spf1 include:sendgrid.net ~all`
- **Mailgun**: `v=spf1 include:mailgun.org ~all`
- **AWS SES**: `v=spf1 include:amazonses.com ~all`
- **Contabo/VPS**: `v=spf1 a mx ip4:YOUR_SERVER_IP ~all`

### 2. DKIM Signing (Recommended)

#### Generate DKIM Keys

```bash
# Generate DKIM private key
openssl genrsa -out dkim_private.pem 1024

# Generate DKIM public key
openssl rsa -in dkim_private.pem -pubout -out dkim_public.pem

# Extract public key for DNS
cat dkim_public.pem | grep -v "BEGIN\|END" | tr -d '\n'
```

#### Add DKIM to DNS

```
Type: TXT
Name: default._domainkey
Value: v=DKIM1; k=rsa; p=YOUR_PUBLIC_KEY_HERE
```

#### Configure DKIM in Application

Add to `.env`:

```env
DKIM_DOMAIN=yourdomain.com
DKIM_SELECTOR=default
DKIM_PRIVATE_KEY=/path/to/dkim_private.pem
DKIM_PASSPHRASE=
```

Add to `config/config.php`:

```php
define('DKIM_DOMAIN', env('DKIM_DOMAIN', ''));
define('DKIM_SELECTOR', env('DKIM_SELECTOR', 'default'));
define('DKIM_PRIVATE_KEY', env('DKIM_PRIVATE_KEY', ''));
define('DKIM_PASSPHRASE', env('DKIM_PASSPHRASE', ''));
```

### 3. DMARC Policy (Recommended)

Add DMARC record to DNS:

```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com; ruf=mailto:dmarc@yourdomain.com; fo=1
```

Policy options:
- `p=none` - Monitor only (recommended for testing)
- `p=quarantine` - Send suspicious emails to spam
- `p=reject` - Reject unauthorized emails

### 4. Reverse DNS (PTR Record)

Ensure your server IP has proper reverse DNS:

```bash
# Check current PTR
dig -x YOUR_SERVER_IP +short

# Should return: mail.yourdomain.com
```

Contact your hosting provider to set PTR record if not configured.

## SMTP Provider Recommendations

### Option 1: Third-Party SMTP (Recommended)

**SendGrid** (Free tier: 100 emails/day)
```env
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key
SMTP_ENCRYPTION=tls
```

**Mailgun** (Free tier: 1000 emails/month)
```env
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USERNAME=postmaster@your-domain.mailgun.org
SMTP_PASSWORD=your-mailgun-smtp-password
SMTP_ENCRYPTION=tls
```

**AWS SES** (Pay as you go)
```env
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USERNAME=your-aws-smtp-username
SMTP_PASSWORD=your-aws-smtp-password
SMTP_ENCRYPTION=tls
```

### Option 2: Server SMTP (Contabo/VPS)

Install Postfix:
```bash
sudo apt-get update
sudo apt-get install postfix mailutils
```

Configure Postfix for relay:
```bash
sudo nano /etc/postfix/main.cf
```

Add/modify:
```
myhostname = mail.yourdomain.com
mydomain = yourdomain.com
myorigin = $mydomain
relayhost =
inet_interfaces = all
```

Configure application:
```env
SMTP_HOST=localhost
SMTP_PORT=25
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_ENCRYPTION=
```

## Migration to Robust Email Service

### Update email sending code:

```php
// Old way (unreliable)
mail($to, $subject, $body, $headers);

// New way (reliable)
require_once __DIR__ . '/includes/RobustEmailService.php';

$emailService = new RobustEmailService();
$emailService->sendEmail($to, $subject, $body, [
    'to_name' => 'User Name',
    'reply_to' => 'support@yourdomain.com',
    'priority' => 1, // 1 = High, 3 = Normal, 5 = Low
    'attachments' => [
        ['path' => '/path/to/file.pdf', 'name' => 'Invoice.pdf']
    ]
]);

// Or queue for batch processing
$emailService->queueEmail($to, $subject, $body, [
    'priority' => 3,
    'scheduled_at' => '2024-01-01 12:00:00' // Optional
]);
```

## Email Queue Processing

### Manual Processing

```bash
php process_email_queue.php
```

### Automated Processing (Cron)

```bash
# Edit crontab
crontab -e

# Add this line
*/5 * * * * /usr/bin/php /var/www/html/process_email_queue.php >> /var/log/email_queue.log 2>&1
```

### Monitor Queue

```sql
-- Check queue status
SELECT status, COUNT(*) as count 
FROM email_queue 
GROUP BY status;

-- View failed emails
SELECT id, to_email, subject, error_message, attempts
FROM email_queue
WHERE status = 'failed'
ORDER BY created_at DESC
LIMIT 10;

-- Retry failed emails
UPDATE email_queue
SET status = 'pending', attempts = 0
WHERE status = 'failed' AND attempts < max_attempts;
```

## Testing Email Deliverability

### 1. Test SMTP Connection

```php
require_once __DIR__ . '/includes/RobustEmailService.php';

$emailService = new RobustEmailService();
if ($emailService->testConnection()) {
    echo "SMTP connection successful!";
} else {
    echo "SMTP connection failed: " . $emailService->getLastError();
}
```

### 2. Send Test Email

```php
$result = $emailService->sendEmail(
    'test@example.com',
    'Test Email',
    '<h1>Test Email</h1><p>This is a test email.</p>',
    ['priority' => 1]
);

if ($result) {
    echo "Email sent successfully!";
} else {
    echo "Email failed: " . $emailService->getLastError();
}
```

### 3. Check Email Authentication

Use these tools to test:
- **MX Toolbox**: https://mxtoolbox.com/SuperTool.aspx
- **Mail Tester**: https://www.mail-tester.com/
- **DMARC Analyzer**: https://dmarcian.com/dmarc-inspector/

## Common Issues & Solutions

### Issue 1: Emails go to spam

**Solutions:**
1. Configure SPF, DKIM, and DMARC records
2. Use a reputable SMTP provider
3. Warm up your sending domain (gradually increase volume)
4. Avoid spam trigger words in subject/body
5. Include unsubscribe link
6. Maintain good sender reputation

### Issue 2: Emails not sending

**Solutions:**
1. Check SMTP credentials in .env
2. Verify firewall allows outbound port 587/465/25
3. Check email queue for errors
4. Test SMTP connection
5. Review error logs

### Issue 3: Slow email delivery

**Solutions:**
1. Use email queue with cron processing
2. Increase queue processing frequency
3. Use asynchronous sending
4. Consider third-party SMTP provider

### Issue 4: Bounced emails

**Solutions:**
1. Validate email addresses before sending
2. Maintain clean email list
3. Remove hard bounces immediately
4. Monitor bounce rates
5. Use double opt-in for subscriptions

## Email Templates Best Practices

1. **Use responsive HTML templates**
2. **Include plain text alternative**
3. **Add unsubscribe link** (required by law)
4. **Include physical address** (CAN-SPAM compliance)
5. **Use inline CSS** (better email client support)
6. **Test across email clients** (Gmail, Outlook, Apple Mail, etc.)

## Monitoring & Maintenance

### Daily Checks
- Monitor email queue status
- Check for failed emails
- Review bounce rates

### Weekly Tasks
- Analyze email deliverability metrics
- Clean up old queue entries
- Review spam complaints

### Monthly Review
- Email reputation check
- SPF/DKIM/DMARC validation
- Provider performance review

## Support & Troubleshooting

### Check Email Logs

```sql
SELECT * FROM email_logs
WHERE sent_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)
ORDER BY sent_at DESC;
```

### Debug Mode

Enable debug in development:
```php
// In .env
APP_DEBUG=true

// PHPMailer will output detailed SMTP conversation
```

### Contact Support

If issues persist:
1. Check error logs: `tail -f /var/log/email_queue.log`
2. Review SMTP provider documentation
3. Contact SMTP provider support
4. Check firewall/server logs

## Compliance

### CAN-SPAM Act (US)
- Include physical address
- Add unsubscribe link
- Honor opt-out requests within 10 days
- Don't use deceptive headers/subject lines

### GDPR (EU)
- Get explicit consent before sending
- Provide easy unsubscribe
- Maintain records of consent
- Allow data export/deletion

### CASL (Canada)
- Obtain express or implied consent
- Identify sender clearly
- Provide unsubscribe mechanism
- Include contact information

## Conclusion

Following this guide ensures reliable email delivery with:
- ✅ Proper SMTP configuration
- ✅ Email authentication (SPF/DKIM/DMARC)
- ✅ Queue-based processing with retry logic
- ✅ Comprehensive logging and monitoring
- ✅ Legal compliance (CAN-SPAM, GDPR, CASL)

All emails and notifications will be delivered automatically without issues when properly configured.
