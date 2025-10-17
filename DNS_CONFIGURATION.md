# DNS Configuration for fezamarket.com Email Deliverability

## Server Information
- **Server IP**: 5.189.180.149
- **Mail Server Hostname**: mail.fezamarket.com
- **Domain**: fezamarket.com

## Required DNS Records

Add these DNS records to your domain registrar or DNS provider (e.g., Cloudflare, Namecheap, GoDaddy):

### 1. A Record for Mail Server
```
Type: A
Name: mail
Value: 5.189.180.149
TTL: 3600 (or Auto)
```

### 2. MX Record
```
Type: MX
Name: @ (or blank, or fezamarket.com)
Value: mail.fezamarket.com
Priority: 10
TTL: 3600 (or Auto)
```

### 3. SPF Record
```
Type: TXT
Name: @ (or blank, or fezamarket.com)
Value: v=spf1 ip4:5.189.180.149 a mx -all
TTL: 3600 (or Auto)
```

**Explanation**:
- `v=spf1`: SPF version 1
- `ip4:5.189.180.149`: Authorize email sending from this IP address
- `a`: Authorize IPs in A records
- `mx`: Authorize IPs in MX records
- `-all`: Reject all other sources (strict policy)

**Note**: During testing, you can use `~all` (soft fail) instead of `-all` (hard fail).

### 4. DKIM Record
```
Type: TXT
Name: default._domainkey
Value: v=DKIM1; k=rsa; p=<YOUR_PUBLIC_KEY_HERE>
TTL: 3600 (or Auto)
```

**How to generate the public key**:
1. Generate DKIM private key on your server:
   ```bash
   sudo mkdir -p /etc/mail/dkim
   sudo openssl genrsa -out /etc/mail/dkim/fezamarket.com.key 2048
   sudo chmod 600 /etc/mail/dkim/fezamarket.com.key
   ```

2. Extract public key:
   ```bash
   sudo openssl rsa -in /etc/mail/dkim/fezamarket.com.key -pubout -outform PEM | grep -v "BEGIN PUBLIC KEY" | grep -v "END PUBLIC KEY" | tr -d '\n'
   ```

3. Copy the output and replace `<YOUR_PUBLIC_KEY_HERE>` in the DNS record above.

**Example** (do not use this key, generate your own):
```
Type: TXT
Name: default._domainkey
Value: v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1234567890...
TTL: 3600
```

### 5. DMARC Record
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@fezamarket.com; ruf=mailto:postmaster@fezamarket.com; fo=1; adkim=r; aspf=r
TTL: 3600 (or Auto)
```

**Explanation**:
- `v=DMARC1`: DMARC version 1
- `p=quarantine`: Policy for failed emails (quarantine suspicious emails)
- `rua`: Send aggregate reports to this email
- `ruf`: Send forensic reports to this email
- `fo=1`: Generate reports for any authentication failure
- `adkim=r`: Relaxed DKIM alignment
- `aspf=r`: Relaxed SPF alignment

**Production Note**: After testing, you can change `p=quarantine` to `p=reject` for stricter enforcement.

### 6. Reverse DNS (PTR Record)

**This must be configured by your hosting provider!**

Contact your VPS/dedicated server hosting provider and request:
- **IP Address**: 5.189.180.149
- **PTR Record**: mail.fezamarket.com

**Critical**: Without proper reverse DNS, many mail servers will reject your emails.

## Verification Commands

After adding DNS records, wait 10-60 minutes for propagation, then verify:

```bash
# Verify A record
dig A mail.fezamarket.com +short
# Expected: 5.189.180.149

# Verify MX record
dig MX fezamarket.com +short
# Expected: 10 mail.fezamarket.com.

# Verify SPF record
dig TXT fezamarket.com +short | grep spf
# Expected: "v=spf1 ip4:5.189.180.149 a mx -all"

# Verify DKIM record
dig TXT default._domainkey.fezamarket.com +short
# Expected: "v=DKIM1; k=rsa; p=..."

# Verify DMARC record
dig TXT _dmarc.fezamarket.com +short
# Expected: "v=DMARC1; p=quarantine; ..."

# Verify reverse DNS
dig -x 5.189.180.149 +short
# Expected: mail.fezamarket.com.
```

## Online Verification Tools

Use these tools to verify your DNS configuration:

1. **MXToolbox - Complete Check**
   - https://mxtoolbox.com/SuperTool.aspx
   - Enter: fezamarket.com
   - Check: MX, SPF, DKIM, DMARC, Blacklist

2. **DKIM Validator**
   - https://dkimvalidator.com
   - Send email to the provided address
   - Verify DKIM signature passes

3. **Mail Tester - Deliverability Score**
   - https://www.mail-tester.com
   - Send email to the provided address
   - Aim for score: 10/10

4. **Google Admin Toolbox**
   - https://toolbox.googleapps.com/apps/checkmx/
   - Enter: fezamarket.com
   - Verify MX and other records

## Example Cloudflare Configuration

If using Cloudflare as your DNS provider:

### A Record
- Type: `A`
- Name: `mail`
- IPv4 address: `5.189.180.149`
- Proxy status: DNS only (grey cloud icon)
- TTL: Auto

### MX Record
- Type: `MX`
- Name: `@`
- Mail server: `mail.fezamarket.com`
- Priority: `10`
- TTL: Auto

### TXT Records

**SPF**:
- Type: `TXT`
- Name: `@`
- Content: `v=spf1 ip4:5.189.180.149 a mx -all`
- TTL: Auto

**DKIM**:
- Type: `TXT`
- Name: `default._domainkey`
- Content: `v=DKIM1; k=rsa; p=YOUR_PUBLIC_KEY_HERE`
- TTL: Auto

**DMARC**:
- Type: `TXT`
- Name: `_dmarc`
- Content: `v=DMARC1; p=quarantine; rua=mailto:postmaster@fezamarket.com; ruf=mailto:postmaster@fezamarket.com; fo=1; adkim=r; aspf=r`
- TTL: Auto

## Common Issues

### 1. DNS Not Propagating
- Wait 1-2 hours
- Clear DNS cache: `sudo systemd-resolve --flush-caches`
- Use different DNS server to test: `dig @8.8.8.8 fezamarket.com MX`

### 2. DKIM Public Key Too Long
- Split the key into multiple strings:
  ```
  v=DKIM1; k=rsa; p=MIIBIjANBgkqhki...first_part "second_part...rest_of_key"
  ```

### 3. SPF Record Not Found
- Make sure the record name is `@` or blank (not `fezamarket.com`)
- Check for typos in the value
- Only one SPF record is allowed per domain

### 4. Reverse DNS Not Set
- Contact your hosting provider
- Provide both IP (5.189.180.149) and hostname (mail.fezamarket.com)
- May take 24-48 hours to propagate

## Summary Checklist

- [ ] A Record: mail.fezamarket.com → 5.189.180.149
- [ ] MX Record: fezamarket.com → mail.fezamarket.com (priority 10)
- [ ] SPF Record: v=spf1 ip4:5.189.180.149 a mx -all
- [ ] DKIM Keys Generated on server
- [ ] DKIM Record: default._domainkey.fezamarket.com with public key
- [ ] DMARC Record: _dmarc.fezamarket.com with policy
- [ ] Reverse DNS (PTR): 5.189.180.149 → mail.fezamarket.com
- [ ] All records verified with dig commands
- [ ] Deliverability tested with mail-tester.com (score > 8/10)

## Next Steps

After configuring DNS:
1. Wait for DNS propagation (10-60 minutes)
2. Verify all records with dig commands
3. Follow server setup instructions in DIRECT_EMAIL_SETUP.md
4. Install and configure Postfix on the server
5. Test email sending
6. Monitor deliverability and make adjustments

---

**Last Updated**: 2025-10-17  
**Domain**: fezamarket.com  
**Server IP**: 5.189.180.149  
**Mail Server**: mail.fezamarket.com
