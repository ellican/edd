<?php
require_once __DIR__ . '/../includes/init.php';
includeHeader('Account & Login - FezaMarket Help');
?>

<div class="container">
    <div class="help-header">
        <h1>Account & Login</h1>
        <p>Manage your account settings and security</p>
    </div>

    <div class="help-content">
        <section class="help-section">
            <h2>Creating Your Account</h2>
            <div class="steps">
                <div class="step">
                    <div class="step-number">1</div>
                    <h3>Click Register</h3>
                    <p>Click "Register" or "Sign Up" on the homepage.</p>
                </div>
                <div class="step">
                    <div class="step-number">2</div>
                    <h3>Enter Details</h3>
                    <p>Provide your email, name, and create a strong password.</p>
                </div>
                <div class="step">
                    <div class="step-number">3</div>
                    <h3>Verify Email</h3>
                    <p>Check your email and click the verification link.</p>
                </div>
                <div class="step">
                    <div class="step-number">4</div>
                    <h3>Start Shopping</h3>
                    <p>Your account is ready! Start browsing and shopping.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Account Settings</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>👤 Personal Information</h3>
                    <p>Update your profile:</p>
                    <ul>
                        <li>Name and contact details</li>
                        <li>Profile picture</li>
                        <li>Shipping addresses</li>
                        <li>Phone number</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>🔒 Password & Security</h3>
                    <p>Keep your account secure:</p>
                    <ul>
                        <li>Change password regularly</li>
                        <li>Enable two-factor authentication</li>
                        <li>Review login activity</li>
                        <li>Security questions</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>💳 Payment Methods</h3>
                    <p>Manage your payment options:</p>
                    <ul>
                        <li>Add credit/debit cards</li>
                        <li>Set default payment method</li>
                        <li>Remove old cards</li>
                        <li>Billing addresses</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>📧 Email Preferences</h3>
                    <p>Control what emails you receive:</p>
                    <ul>
                        <li>Order updates</li>
                        <li>Promotional emails</li>
                        <li>Newsletter subscription</li>
                        <li>Account notifications</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Login Help</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>🔑 Forgot Password</h3>
                    <p>Reset your password easily:</p>
                    <ol>
                        <li>Click "Forgot Password" on login page</li>
                        <li>Enter your email address</li>
                        <li>Check email for reset link</li>
                        <li>Create new password</li>
                    </ol>
                </div>
                <div class="help-item">
                    <h3>❌ Can't Login</h3>
                    <p>Troubleshooting login issues:</p>
                    <ul>
                        <li>Check email address spelling</li>
                        <li>Verify caps lock is off</li>
                        <li>Clear browser cookies/cache</li>
                        <li>Try different browser</li>
                        <li>Reset your password</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Account Security</h2>
            <div class="help-item">
                <h3>🛡️ Keeping Your Account Safe</h3>
                <ul>
                    <li><strong>Strong Password:</strong> Use combination of letters, numbers, and symbols</li>
                    <li><strong>Unique Password:</strong> Don't reuse passwords from other sites</li>
                    <li><strong>Two-Factor Authentication:</strong> Add extra layer of security</li>
                    <li><strong>Watch for Phishing:</strong> We'll never ask for password via email</li>
                    <li><strong>Secure Connection:</strong> Always look for HTTPS in URL</li>
                    <li><strong>Log Out:</strong> Sign out when using shared computers</li>
                </ul>
            </div>
        </section>

        <section class="help-section">
            <h2>Frequently Asked Questions</h2>
            <div class="help-item">
                <h3>Can I change my email address?</h3>
                <p>Yes, go to Account Settings > Personal Information to update your email. You'll need to verify the new email address.</p>
            </div>
            <div class="help-item">
                <h3>How do I delete my account?</h3>
                <p>Contact customer support to request account deletion. Note that this action is permanent and cannot be undone.</p>
            </div>
            <div class="help-item">
                <h3>Why do I need to verify my email?</h3>
                <p>Email verification ensures account security and allows you to receive order updates and important notifications.</p>
            </div>
            <div class="help-item">
                <h3>Can I have multiple accounts?</h3>
                <p>We recommend using one account per person. Multiple accounts may result in account suspension.</p>
            </div>
        </section>

        <div class="cta-section">
            <h2>Need Account Help?</h2>
            <p>We're here to assist you with any account issues</p>
            <a href="/account.php" class="btn btn-primary btn-lg">Go to My Account</a>
            <a href="/contact.php" class="btn btn-outline btn-lg">Contact Support</a>
        </div>
    </div>
</div>

<style>
.help-header{background:linear-gradient(135deg,#0654ba,#1e40af);color:white;text-align:center;padding:60px 20px;margin-bottom:40px;border-radius:12px}
.help-header h1{margin:0 0 10px 0;font-size:36px}
.help-header p{margin:0;font-size:18px;opacity:0.9}
.help-content{max-width:1200px;margin:0 auto;padding:0 20px 40px}
.help-section{margin-bottom:50px}
.help-section h2{font-size:28px;margin-bottom:25px;color:#1f2937;border-bottom:2px solid #0654ba;padding-bottom:10px}
.steps{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:25px;margin-top:30px}
.step{background:white;padding:25px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.1);text-align:center}
.step-number{width:50px;height:50px;background:#0654ba;color:white;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:bold;margin:0 auto 15px}
.step h3{margin:10px 0;color:#1f2937}
.help-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px;margin-top:20px}
.help-item{background:white;padding:25px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.1)}
.help-item h3{margin-top:0;margin-bottom:15px;color:#1f2937;font-size:20px}
.help-item ul,.help-item ol{margin:15px 0;padding-left:25px}
.help-item li{margin-bottom:8px;color:#374151}
.cta-section{text-align:center;padding:40px;background:linear-gradient(135deg,#f9fafb 0%,#e5e7eb 100%);border-radius:12px;margin-top:40px}
.cta-section h2{margin-bottom:20px}
.btn-lg{padding:15px 40px;font-size:18px}
@media (max-width:768px){.help-grid,.steps{grid-template-columns:1fr}}
</style>

<?php includeFooter(); ?>
