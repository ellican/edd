<?php
require_once __DIR__ . '/../includes/init.php';
includeHeader('Creating an Account - FezaMarket Help');
?>

<div class="container">
    <div class="help-header">
        <h1>Creating an Account</h1>
        <p>Get started with FezaMarket in minutes</p>
    </div>

    <div class="help-content">
        <section class="help-section">
            <h2>Why Create an Account?</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>🛒 Faster Checkout</h3>
                    <p>Save your shipping address and payment info for quick, easy purchases.</p>
                </div>
                <div class="help-item">
                    <h3>📦 Order Tracking</h3>
                    <p>Track all your orders in one place and view your complete purchase history.</p>
                </div>
                <div class="help-item">
                    <h3>❤️ Wishlist & Saved Items</h3>
                    <p>Save products you love and get notified about price drops and sales.</p>
                </div>
                <div class="help-item">
                    <h3>🎁 Exclusive Deals</h3>
                    <p>Access member-only discounts, early access to sales, and special offers.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>How to Create Your Account</h2>
            <div class="steps">
                <div class="step">
                    <div class="step-number">1</div>
                    <h3>Click Register</h3>
                    <p>Find the "Register" or "Sign Up" button in the top right corner of any page.</p>
                </div>
                <div class="step">
                    <div class="step-number">2</div>
                    <h3>Enter Your Info</h3>
                    <p>Provide your email address, name, and create a secure password.</p>
                </div>
                <div class="step">
                    <div class="step-number">3</div>
                    <h3>Verify Email</h3>
                    <p>Check your inbox for a verification email and click the confirmation link.</p>
                </div>
                <div class="step">
                    <div class="step-number">4</div>
                    <h3>Complete Profile</h3>
                    <p>Add shipping address and payment method to streamline future purchases.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Account Requirements</h2>
            <div class="help-item">
                <h3>📋 What You'll Need</h3>
                <ul>
                    <li><strong>Email Address:</strong> Valid email for account verification and order updates</li>
                    <li><strong>Password:</strong> At least 8 characters with letters and numbers</li>
                    <li><strong>Name:</strong> First and last name for shipping and account identification</li>
                    <li><strong>Age:</strong> Must be 18 or older (or 13+ with parental consent)</li>
                </ul>
            </div>
        </section>

        <section class="help-section">
            <h2>Password Tips</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>🔐 Create a Strong Password</h3>
                    <ul>
                        <li>Use 8+ characters</li>
                        <li>Mix uppercase and lowercase letters</li>
                        <li>Include numbers</li>
                        <li>Add special characters (@, #, $, etc.)</li>
                        <li>Avoid common words or personal info</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>✅ Password Best Practices</h3>
                    <ul>
                        <li>Use unique password for FezaMarket</li>
                        <li>Don't share with anyone</li>
                        <li>Change it periodically</li>
                        <li>Use a password manager</li>
                        <li>Enable two-factor authentication</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Email Verification</h2>
            <div class="help-item">
                <h3>📧 Why Verify Your Email?</h3>
                <p>Email verification helps us:</p>
                <ul>
                    <li>Confirm you're the account owner</li>
                    <li>Send order confirmations and shipping updates</li>
                    <li>Protect your account from unauthorized access</li>
                    <li>Provide password reset options</li>
                    <li>Send important account notifications</li>
                </ul>
                <p><strong>Didn't receive the email?</strong> Check your spam folder or request a new verification email from your account settings.</p>
            </div>
        </section>

        <section class="help-section">
            <h2>Frequently Asked Questions</h2>
            <div class="help-item">
                <h3>Do I need an account to shop?</h3>
                <p>No, you can check out as a guest. However, creating an account offers many benefits like order tracking and saved addresses.</p>
            </div>
            <div class="help-item">
                <h3>Is creating an account free?</h3>
                <p>Yes! Creating a FezaMarket account is completely free with no hidden fees.</p>
            </div>
            <div class="help-item">
                <h3>Can I use my social media account to sign up?</h3>
                <p>Currently, we require email registration for security purposes. Social login may be available in the future.</p>
            </div>
            <div class="help-item">
                <h3>What if the email I want to use is already taken?</h3>
                <p>Each email can only be associated with one account. Try using a different email or recover your existing account if you forgot the password.</p>
            </div>
        </section>

        <div class="cta-section">
            <h2>Ready to Get Started?</h2>
            <p>Create your free account today and start shopping!</p>
            <a href="/register.php" class="btn btn-primary btn-lg">Create Account</a>
            <a href="/login.php" class="btn btn-outline btn-lg">Already Have Account? Log In</a>
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
.help-item ul{margin:15px 0;padding-left:25px}
.help-item li{margin-bottom:8px;color:#374151}
.cta-section{text-align:center;padding:40px;background:linear-gradient(135deg,#f9fafb 0%,#e5e7eb 100%);border-radius:12px;margin-top:40px}
.cta-section h2{margin-bottom:20px}
.btn-lg{padding:15px 40px;font-size:18px}
@media (max-width:768px){.help-grid,.steps{grid-template-columns:1fr}}
</style>

<?php includeFooter(); ?>
