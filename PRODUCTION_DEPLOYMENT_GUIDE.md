# Quick Start Guide - Production Deployment

## Executive Summary

The email system has been reconfigured to send emails **directly from your server** at IP **5.189.180.149** using the domain **fezamarket.com**, eliminating dependency on third-party SMTP services like SendGrid or Mailgun.

## What You Need to Do

### 1. Server Setup (30-60 minutes)

SSH into your production server (5.189.180.149) and run:

```bash
# Install Postfix
sudo apt update
sudo apt install postfix mailutils -y

# When prompted, select:
# - General type: Internet Site
# - System mail name: mail.fezamarket.com

# Set hostname
sudo hostnamectl set-hostname mail.fezamarket.com

# Edit /etc/hosts
sudo nano /etc/hosts
# Add: 5.189.180.149  mail.fezamarket.com mail

# Restart Postfix
sudo systemctl restart postfix
sudo systemctl enable postfix

# Verify Postfix is running
sudo systemctl status postfix
```

### 2. DNS Configuration (10 minutes)

Login to your DNS provider (Cloudflare, Namecheap, GoDaddy, etc.) and add these records:

#### A Record
```
Type: A
Name: mail
Value: 5.189.180.149
```

#### MX Record
```
Type: MX
Name: @
Value: mail.fezamarket.com
Priority: 10
```

#### SPF Record
```
Type: TXT
Name: @
Value: v=spf1 ip4:5.189.180.149 a mx -all
```

### 3. DKIM Setup (15 minutes)

On your server:

```bash
# Generate DKIM keys
sudo mkdir -p /etc/mail/dkim
sudo openssl genrsa -out /etc/mail/dkim/fezamarket.com.key 2048
sudo chmod 600 /etc/mail/dkim/fezamarket.com.key

# Extract public key for DNS
sudo openssl rsa -in /etc/mail/dkim/fezamarket.com.key -pubout -outform PEM | \
  grep -v "BEGIN PUBLIC KEY" | grep -v "END PUBLIC KEY" | tr -d '\n'
# Copy the output
```

Add DNS TXT record:
```
Type: TXT
Name: default._domainkey
Value: v=DKIM1; k=rsa; p=<PASTE_PUBLIC_KEY_HERE>
```

### 4. DMARC Record (2 minutes)

Add DNS TXT record:
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@fezamarket.com
```

### 5. Reverse DNS (Contact Hosting Provider)

Contact your hosting provider (VPS/dedicated server) and request:
- **IP**: 5.189.180.149
- **PTR Record**: mail.fezamarket.com

This is **CRITICAL** for email deliverability!

### 6. Application Configuration (5 minutes)

On your production server, update `.env` file:

```bash
# Navigate to application directory
cd /path/to/your/application

# Edit .env
nano .env

# Update these settings:
MAIL_METHOD=smtp
SMTP_HOST=localhost
SMTP_PORT=25
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_ENCRYPTION=none
FROM_EMAIL=no-reply@fezamarket.com
FROM_NAME="FezaMarket"

# Add DKIM configuration
DKIM_DOMAIN=fezamarket.com
DKIM_SELECTOR=default
DKIM_PRIVATE_KEY=/etc/mail/dkim/fezamarket.com.key
DKIM_PASSPHRASE=
```

Save and exit.

### 7. Test Email Sending (5 minutes)

```bash
# Navigate to application directory
cd /path/to/your/application

# Run test script
php test_email_config.php

# When prompted, send test email to your personal email address
# Check your inbox (and spam folder)
```

### 8. Verify Deliverability (10 minutes)

1. Visit https://www.mail-tester.com
2. Send a test email to the provided address
3. Check your score (aim for 8-10/10)
4. Fix any issues identified

## Verification Checklist

- [ ] Postfix installed and running (`sudo systemctl status postfix`)
- [ ] Server hostname is mail.fezamarket.com (`hostname`)
- [ ] DNS A record added (mail.fezamarket.com → 5.189.180.149)
- [ ] DNS MX record added (fezamarket.com → mail.fezamarket.com)
- [ ] DNS SPF record added
- [ ] DKIM keys generated on server
- [ ] DNS DKIM record added
- [ ] DNS DMARC record added
- [ ] Reverse DNS requested from hosting provider
- [ ] .env file updated with localhost SMTP settings
- [ ] Test email sent successfully
- [ ] Email received in inbox (not spam)
- [ ] Mail-tester.com score ≥ 8/10

## Common Issues

### Port 25 Blocked
Many VPS providers block port 25. Contact your provider to:
- Unblock port 25 (outbound)
- Explain you're setting up a mail server for transactional emails
- Provide your domain and IP information

### Emails Going to Spam
- Verify all DNS records are correct
- Ensure reverse DNS is configured
- Wait 24-48 hours for DNS propagation
- Warm up your IP by sending gradually (start with 50-100 emails/day)

### Postfix Not Starting
```bash
# Check logs
sudo tail -f /var/log/mail.log

# Check configuration
sudo postfix check

# Restart
sudo systemctl restart postfix
```

## Support Resources

### Documentation Files (in this repository)
- **DIRECT_EMAIL_SETUP.md** - Complete server setup guide
- **DNS_CONFIGURATION.md** - Detailed DNS configuration
- **EMAIL_REVISION_SUMMARY.md** - What changed and why
- **test_email_config.php** - Configuration test script

### Online Tools
- **DNS Checker**: https://mxtoolbox.com
- **Email Tester**: https://www.mail-tester.com
- **DKIM Validator**: https://dkimvalidator.com
- **Blacklist Check**: https://mxtoolbox.com/blacklists.aspx

### Commands Reference

```bash
# Check Postfix status
sudo systemctl status postfix

# View mail logs
sudo tail -f /var/log/mail.log

# Check mail queue
mailq

# Test SMTP connection
telnet localhost 25

# Send test email
echo "Test" | mail -s "Test Email" your@email.com

# Verify DNS records
dig MX fezamarket.com +short
dig TXT fezamarket.com +short
dig TXT default._domainkey.fezamarket.com +short
dig -x 5.189.180.149 +short
```

## Timeline

- **Server Setup**: 30-60 minutes
- **DNS Configuration**: 10-15 minutes
- **DNS Propagation**: 10 minutes - 2 hours
- **Reverse DNS Request**: 24-48 hours (depends on hosting provider)
- **Testing**: 15-30 minutes
- **Total**: 1-3 days (mostly waiting for DNS)

## Expected Results

After completing all steps:

✅ **Emails sent** directly from your server (5.189.180.149)  
✅ **No third-party** SMTP services required  
✅ **All email types** working:
   - User verification emails
   - Password reset emails
   - Order confirmations
   - Notifications

✅ **Email deliverability**:
   - Emails reach inbox (not spam)
   - SPF: PASS
   - DKIM: PASS
   - DMARC: PASS
   - Deliverability score: 8-10/10

## Production Rollout Plan

### Phase 1: Setup (Day 1)
- [ ] Install Postfix on server
- [ ] Configure DNS records
- [ ] Generate DKIM keys
- [ ] Request reverse DNS

### Phase 2: Testing (Day 1-2)
- [ ] Wait for DNS propagation
- [ ] Run test_email_config.php
- [ ] Send test emails
- [ ] Check deliverability score

### Phase 3: Monitoring (Day 2-3)
- [ ] Confirm reverse DNS is active
- [ ] Monitor email logs
- [ ] Check bounce rates
- [ ] Verify all email types working

### Phase 4: Optimization (Week 1)
- [ ] Review DMARC reports
- [ ] Adjust SPF/DKIM if needed
- [ ] Monitor IP reputation
- [ ] Set up automated monitoring

## Contact

For questions or issues during deployment:
1. Review the detailed documentation files
2. Check the troubleshooting sections
3. Test with the provided test script
4. Verify DNS configuration online

## Next Steps After Deployment

1. **Set up monitoring**:
   ```bash
   # Add to crontab for queue processing
   */5 * * * * /usr/bin/php /path/to/process_email_queue.php
   ```

2. **Monitor deliverability**:
   - Check mail logs daily for first week
   - Review bounce rates
   - Monitor spam complaints

3. **Gradual ramp-up**:
   - Start with low volume (50-100 emails/day)
   - Gradually increase over 2-4 weeks
   - Monitor reputation and deliverability

4. **Regular maintenance**:
   - Weekly: Check mail queue and logs
   - Monthly: Review DMARC reports
   - Quarterly: Update DKIM keys if needed

---

**Server IP**: 5.189.180.149  
**Domain**: fezamarket.com  
**Mail Server**: mail.fezamarket.com  
**Status**: Ready for production deployment
