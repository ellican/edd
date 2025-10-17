# Direct Email Sending from Server - Complete Setup Guide

## Overview

This guide configures the email system to send emails **directly from the server** at IP **5.189.180.149** using the domain **fezamarket.com**, without relying on any third-party SMTP services or APIs.

## Server Information

- **Server IP**: 5.189.180.149
- **Domain**: fezamarket.com
- **Email Addresses**: no-reply@fezamarket.com, support@fezamarket.com

## Prerequisites

1. Root or sudo access to the server
2. Domain DNS access for adding records
3. Server with static IP address (5.189.180.149)
4. Properly configured hostname and reverse DNS

## Step 1: Install and Configure Postfix (Recommended MTA)

### Install Postfix

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postfix mailutils -y

# CentOS/RHEL
sudo yum install postfix mailx -y
```

### Configure Postfix

1. Edit main Postfix configuration:

```bash
sudo nano /etc/postfix/main.cf
```

2. Add/modify the following configuration:

```conf
# Basic Settings
myhostname = mail.fezamarket.com
mydomain = fezamarket.com
myorigin = $mydomain
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128

# SMTP Settings
inet_interfaces = all
inet_protocols = ipv4

# Relay Settings (no relay - direct sending)
relayhost =

# Message size limit (10MB)
message_size_limit = 10485760

# Virtual alias maps (optional)
# virtual_alias_maps = hash:/etc/postfix/virtual

# SMTP Security
smtpd_banner = $myhostname ESMTP
smtpd_helo_required = yes
disable_vrfy_command = yes

# TLS Settings (optional but recommended)
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_auth_only = no
smtp_tls_security_level = may
smtpd_tls_security_level = may
smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1

# Authentication (not required for localhost sending)
# smtpd_sasl_auth_enable = yes
# smtpd_sasl_type = dovecot
# smtpd_sasl_path = private/auth
```

3. Restart Postfix:

```bash
sudo systemctl restart postfix
sudo systemctl enable postfix
```

### Verify Postfix is Running

```bash
sudo systemctl status postfix
sudo netstat -tulpn | grep :25
```

## Step 2: Configure Server Hostname and Reverse DNS

### Set Hostname

```bash
sudo hostnamectl set-hostname mail.fezamarket.com
```

### Configure /etc/hosts

```bash
sudo nano /etc/hosts
```

Add:
```
127.0.0.1       localhost
5.189.180.149   mail.fezamarket.com mail
```

### Request Reverse DNS (PTR Record)

Contact your hosting provider (VPS/dedicated server) to set up reverse DNS:

- **IP**: 5.189.180.149
- **PTR Record**: mail.fezamarket.com

**This is CRITICAL for email deliverability!**

## Step 3: Configure DNS Records

### Required DNS Records

Add these DNS records in your domain registrar/DNS provider:

#### 1. A Record for Mail Server

```
Type: A
Name: mail
Value: 5.189.180.149
TTL: 3600
```

#### 2. MX Record

```
Type: MX
Name: @
Value: mail.fezamarket.com
Priority: 10
TTL: 3600
```

#### 3. SPF Record (Sender Policy Framework)

```
Type: TXT
Name: @
Value: v=spf1 ip4:5.189.180.149 a mx ~all
TTL: 3600
```

Explanation:
- `v=spf1`: SPF version 1
- `ip4:5.189.180.149`: Allow emails from this IP
- `a`: Allow emails from IPs in A records
- `mx`: Allow emails from IPs in MX records
- `~all`: Soft fail for others (recommended for testing)

For production, use `v=spf1 ip4:5.189.180.149 -all` (strict)

#### 4. DKIM Record (DomainKeys Identified Mail)

First, generate DKIM keys:

```bash
# Create directory for DKIM keys
sudo mkdir -p /etc/mail/dkim
sudo chmod 750 /etc/mail/dkim

# Generate DKIM private key (2048-bit RSA)
sudo openssl genrsa -out /etc/mail/dkim/fezamarket.com.key 2048

# Set proper permissions
sudo chmod 600 /etc/mail/dkim/fezamarket.com.key

# Extract public key
sudo openssl rsa -in /etc/mail/dkim/fezamarket.com.key -pubout -outform PEM -out /etc/mail/dkim/fezamarket.com.pub

# Format public key for DNS (remove headers and join lines)
sudo cat /etc/mail/dkim/fezamarket.com.pub | grep -v "BEGIN PUBLIC KEY" | grep -v "END PUBLIC KEY" | tr -d '\n'
```

Add DNS TXT record:

```
Type: TXT
Name: default._domainkey
Value: v=DKIM1; k=rsa; p=<YOUR_PUBLIC_KEY_HERE>
TTL: 3600
```

Replace `<YOUR_PUBLIC_KEY_HERE>` with the output from the last command above.

#### 5. DMARC Record (Domain-based Message Authentication)

```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@fezamarket.com; ruf=mailto:postmaster@fezamarket.com; fo=1
TTL: 3600
```

Explanation:
- `p=quarantine`: Quarantine suspicious emails (use `p=reject` for strict enforcement)
- `rua`: Aggregate reports email
- `ruf`: Forensic reports email
- `fo=1`: Generate reports for any failure

### Verify DNS Records

Wait 10-60 minutes for DNS propagation, then verify:

```bash
# Check SPF
dig TXT fezamarket.com +short

# Check DKIM
dig TXT default._domainkey.fezamarket.com +short

# Check DMARC
dig TXT _dmarc.fezamarket.com +short

# Check MX
dig MX fezamarket.com +short

# Check reverse DNS
dig -x 5.189.180.149 +short
```

## Step 4: Configure Application Environment

Update your `.env` file:

```env
# Email Configuration for Direct Server Sending
MAIL_METHOD=smtp
SMTP_HOST=localhost
SMTP_PORT=25
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_ENCRYPTION=none
FROM_EMAIL=no-reply@fezamarket.com
MAIL_FROM_ADDRESS=no-reply@fezamarket.com
MAIL_FROM_NAME="FezaMarket"
SUPPORT_EMAIL=support@fezamarket.com
FROM_NAME="FezaMarket"

# DKIM Configuration
DKIM_DOMAIN=fezamarket.com
DKIM_SELECTOR=default
DKIM_PRIVATE_KEY=/etc/mail/dkim/fezamarket.com.key
DKIM_PASSPHRASE=
```

## Step 5: Test Email Sending

### Test 1: Postfix Command Line

```bash
echo "Test email from Postfix" | mail -s "Postfix Test" your-email@example.com
```

Check your inbox (and spam folder) for the test email.

### Test 2: PHP mail() Function

Create test file `/tmp/test_mail.php`:

```php
<?php
$to = "your-email@example.com";
$subject = "PHP mail() Test";
$message = "This is a test email from PHP mail() function";
$headers = "From: no-reply@fezamarket.com\r\n";
$headers .= "Reply-To: support@fezamarket.com\r\n";
$headers .= "X-Mailer: PHP/" . phpversion();

if (mail($to, $subject, $message, $headers)) {
    echo "Email sent successfully via mail()";
} else {
    echo "Failed to send email via mail()";
}
```

Run:
```bash
php /tmp/test_mail.php
```

### Test 3: Application Email Test

Create test file `/tmp/test_email_service.php`:

```php
<?php
require_once '/home/runner/work/edd/edd/config/config.php';
require_once '/home/runner/work/edd/edd/includes/RobustEmailService.php';

$emailService = new RobustEmailService();

// Test connection
echo "Testing email service...\n";

// Send test email
$result = $emailService->sendEmail(
    'your-email@example.com',
    'FezaMarket Email Test',
    '<h1>Test Email</h1><p>This is a test email from FezaMarket using direct server sending.</p><p>If you receive this, the email configuration is working correctly!</p>',
    [
        'to_name' => 'Test User',
        'priority' => 1
    ]
);

if ($result) {
    echo "✓ Email sent successfully!\n";
} else {
    echo "✗ Email sending failed!\n";
}
```

Run:
```bash
php /tmp/test_email_service.php
```

### Test 4: Check Email Logs

```bash
# Check Postfix logs
sudo tail -f /var/log/mail.log

# Check for errors
sudo grep "error\|warning" /var/log/mail.log | tail -20
```

## Step 6: Email Deliverability Testing

### Test with Online Tools

1. **Mail Tester**: https://www.mail-tester.com
   - Send email to the provided address
   - Check score (aim for 10/10)

2. **DKIM Validator**: https://dkimvalidator.com
   - Send email to provided address
   - Verify DKIM signature

3. **SPF/DMARC Check**: https://mxtoolbox.com
   - Check SPF: https://mxtoolbox.com/spf.aspx
   - Check DMARC: https://mxtoolbox.com/dmarc.aspx

4. **Reverse DNS Check**: https://mxtoolbox.com/ReverseLookup.aspx
   - Verify: 5.189.180.149 → mail.fezamarket.com

### Expected Results

✅ **SPF**: PASS  
✅ **DKIM**: PASS  
✅ **DMARC**: PASS  
✅ **Reverse DNS**: PASS  
✅ **Spam Score**: < 2.0 (lower is better)  
✅ **Deliverability**: Should reach inbox, not spam

## Step 7: Production Email Queue Setup

Set up cron job to process email queue:

```bash
sudo crontab -e
```

Add:
```cron
# Process email queue every 5 minutes
*/5 * * * * /usr/bin/php /home/runner/work/edd/edd/process_email_queue.php >> /var/log/email_queue.log 2>&1

# Clean old email logs weekly (optional)
0 2 * * 0 /usr/bin/php /home/runner/work/edd/edd/scripts/clean_email_logs.php >> /var/log/email_cleanup.log 2>&1
```

## Troubleshooting

### Emails Not Sending

1. **Check Postfix is running**:
   ```bash
   sudo systemctl status postfix
   ```

2. **Check Postfix queue**:
   ```bash
   mailq
   ```

3. **Check logs**:
   ```bash
   sudo tail -100 /var/log/mail.log
   ```

4. **Test Postfix**:
   ```bash
   telnet localhost 25
   EHLO mail.fezamarket.com
   QUIT
   ```

### Emails Going to Spam

1. **Verify DNS records** (SPF, DKIM, DMARC)
2. **Check reverse DNS** (PTR record)
3. **Verify hostname** matches reverse DNS
4. **Check IP reputation**: https://www.mxtoolbox.com/blacklists.aspx
5. **Warm up sending** (start with low volume, gradually increase)

### Port 25 Blocked

Some VPS providers block outbound port 25. Solutions:

1. **Request port 25 unblock** from hosting provider
2. **Use alternate port** (if supported by provider)
3. **Use SMTP relay** on different port (defeats purpose of direct sending)

### DKIM Signing Not Working

1. **Verify DKIM key permissions**:
   ```bash
   sudo ls -l /etc/mail/dkim/fezamarket.com.key
   # Should be: -rw------- (600)
   ```

2. **Check DKIM DNS record**:
   ```bash
   dig TXT default._domainkey.fezamarket.com +short
   ```

3. **Test DKIM**: Use https://dkimvalidator.com

## Security Considerations

### 1. Firewall Configuration

```bash
# Allow SMTP (port 25) outbound
sudo ufw allow out 25/tcp

# Allow SMTP inbound (if receiving emails)
sudo ufw allow 25/tcp
```

### 2. Rate Limiting (Prevent Abuse)

Edit `/etc/postfix/main.cf`:

```conf
# Rate limiting
anvil_rate_time_unit = 60s
smtpd_client_connection_rate_limit = 10
smtpd_client_message_rate_limit = 20
smtpd_client_recipient_rate_limit = 100
```

### 3. Monitor Email Logs

```bash
# Watch for suspicious activity
sudo tail -f /var/log/mail.log | grep -i "reject\|warning\|error"
```

### 4. SPF Enforcement

After testing, update SPF to strict mode:

```
v=spf1 ip4:5.189.180.149 -all
```

## Monitoring & Maintenance

### Daily Tasks

```bash
# Check mail queue
mailq

# Check for errors in last hour
sudo grep "error" /var/log/mail.log | grep "$(date +'%b %d %H')"
```

### Weekly Tasks

```bash
# Check email volume
sudo grep "status=sent" /var/log/mail.log | grep "$(date +'%b %d')" | wc -l

# Check bounce rate
sudo grep "status=bounced" /var/log/mail.log | grep "$(date +'%b')" | wc -l

# Clean mail queue (if needed)
sudo postsuper -d ALL deferred
```

### Monthly Tasks

- Review DNS records
- Check IP reputation
- Review DMARC reports
- Update DKIM keys (if compromised)

## Email Templates & Best Practices

### 1. Include Unsubscribe Link

All marketing emails should include an unsubscribe mechanism (CAN-SPAM compliance).

### 2. Proper HTML Formatting

- Use inline CSS
- Include plain text alternative
- Test on multiple email clients

### 3. Avoid Spam Triggers

- Don't use all caps in subject
- Avoid excessive punctuation!!!
- Don't use misleading subjects
- Include physical address in footer

### 4. Sender Reputation

- Start with low volume (50-100 emails/day)
- Gradually increase over 2-4 weeks
- Monitor bounce rates (keep < 5%)
- Handle unsubscribes promptly

## Backup Configuration

If direct sending from server doesn't work or gets blocked, you can fall back to an SMTP relay:

```env
# Fallback: Use SMTP Relay
MAIL_METHOD=smtp
SMTP_HOST=smtp.yourdomain.com
SMTP_PORT=587
SMTP_USERNAME=username
SMTP_PASSWORD=password
SMTP_ENCRYPTION=tls
```

## Summary Checklist

- [ ] Postfix installed and configured
- [ ] Server hostname set to mail.fezamarket.com
- [ ] Reverse DNS (PTR) configured: 5.189.180.149 → mail.fezamarket.com
- [ ] DNS A record: mail.fezamarket.com → 5.189.180.149
- [ ] DNS MX record: fezamarket.com → mail.fezamarket.com
- [ ] DNS SPF record configured
- [ ] DKIM keys generated and DNS record added
- [ ] DMARC record configured
- [ ] Application .env file updated
- [ ] Test emails sent successfully
- [ ] Email deliverability score > 8/10
- [ ] Emails reaching inbox (not spam)
- [ ] Email queue cron job configured
- [ ] Monitoring and logging set up

## Support & Resources

- **Postfix Documentation**: http://www.postfix.org/documentation.html
- **SPF/DKIM/DMARC Checker**: https://mxtoolbox.com
- **Email Testing**: https://www.mail-tester.com
- **IP Reputation Check**: https://www.mxtoolbox.com/blacklists.aspx

## Conclusion

With this configuration, your server at IP 5.189.180.149 will send emails directly using the fezamarket.com domain without relying on third-party SMTP services. All emails for user verification, password resets, and notifications will be delivered reliably to users' inboxes.

**Key Success Factors**:
1. ✅ Proper DNS configuration (SPF, DKIM, DMARC)
2. ✅ Reverse DNS matching hostname
3. ✅ Clean IP reputation
4. ✅ Gradual sending volume increase
5. ✅ Regular monitoring and maintenance
