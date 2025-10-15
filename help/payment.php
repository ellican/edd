<?php
require_once __DIR__ . '/../includes/init.php';
includeHeader('Payment & Billing - FezaMarket Help');
?>

<div class="container">
    <div class="help-header">
        <h1>Payment & Billing</h1>
        <p>Secure payment methods and billing information</p>
    </div>

    <div class="help-content">
        <section class="help-section">
            <h2>Accepted Payment Methods</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>💳 Credit & Debit Cards</h3>
                    <p>We accept all major cards:</p>
                    <ul>
                        <li>Visa</li>
                        <li>Mastercard</li>
                        <li>American Express</li>
                        <li>Discover</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>🔒 Secure Processing</h3>
                    <p>Your payment security is our priority:</p>
                    <ul>
                        <li>256-bit SSL encryption</li>
                        <li>PCI DSS compliant</li>
                        <li>Powered by Stripe</li>
                        <li>No card details stored on our servers</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Managing Payment Methods</h2>
            <div class="steps">
                <div class="step">
                    <div class="step-number">1</div>
                    <h3>Add Card</h3>
                    <p>Go to Account > Payment Methods and click "Add Card".</p>
                </div>
                <div class="step">
                    <div class="step-number">2</div>
                    <h3>Enter Details</h3>
                    <p>Securely enter your card information.</p>
                </div>
                <div class="step">
                    <div class="step-number">3</div>
                    <h3>Set Default</h3>
                    <p>Choose a default card for faster checkout.</p>
                </div>
                <div class="step">
                    <div class="step-number">4</div>
                    <h3>Manage Cards</h3>
                    <p>Update or remove cards anytime from your account.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Billing & Invoices</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>📄 Order Receipts</h3>
                    <p>Automatic receipts for every purchase:</p>
                    <ul>
                        <li>Email receipt after payment</li>
                        <li>Download from Order History</li>
                        <li>Includes all order details</li>
                        <li>PDF format available</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>💰 Billing Address</h3>
                    <p>Manage your billing information:</p>
                    <ul>
                        <li>Add multiple addresses</li>
                        <li>Set default billing address</li>
                        <li>Update anytime in account settings</li>
                        <li>Can differ from shipping address</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Payment Issues</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>❌ Payment Declined</h3>
                    <p>If your payment is declined:</p>
                    <ul>
                        <li>Verify card details are correct</li>
                        <li>Check card hasn't expired</li>
                        <li>Ensure sufficient funds available</li>
                        <li>Contact your bank if issue persists</li>
                        <li>Try a different payment method</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>🔄 Duplicate Charges</h3>
                    <p>See duplicate charges?</p>
                    <ul>
                        <li>Check both pending and posted transactions</li>
                        <li>Pending charges may drop off</li>
                        <li>Contact us if duplicate posts</li>
                        <li>We'll investigate and refund if error</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>💸 Refunds</h3>
                    <p>How refunds work:</p>
                    <ul>
                        <li>Refunded to original payment method</li>
                        <li>Processing time: 5-7 business days</li>
                        <li>Email notification when processed</li>
                        <li>Contact bank if not received after 10 days</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>🧾 Tax Charges</h3>
                    <p>Understanding taxes on your order:</p>
                    <ul>
                        <li>Sales tax calculated at checkout</li>
                        <li>Based on shipping address</li>
                        <li>Varies by state/country</li>
                        <li>Included in order total</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Promotional Codes & Gift Cards</h2>
            <div class="help-item">
                <h3>🎁 Using Promo Codes</h3>
                <p>Apply promotional codes at checkout:</p>
                <ol>
                    <li>Add items to cart</li>
                    <li>Proceed to checkout</li>
                    <li>Enter promo code in designated field</li>
                    <li>Click "Apply" to see discount</li>
                    <li>Complete your order</li>
                </ol>
                <p><strong>Note:</strong> Only one promo code per order unless otherwise specified.</p>
            </div>
            <div class="help-item">
                <h3>💳 Gift Cards</h3>
                <p>Redeem gift cards:</p>
                <ul>
                    <li>Enter gift card code at checkout</li>
                    <li>Balance applied to order total</li>
                    <li>Remaining balance saved for future use</li>
                    <li>Check balance in your account</li>
                </ul>
            </div>
        </section>

        <section class="help-section">
            <h2>Frequently Asked Questions</h2>
            <div class="help-item">
                <h3>Is my payment information safe?</h3>
                <p>Yes! We use industry-standard encryption and never store your complete card details. All payments are processed securely through Stripe.</p>
            </div>
            <div class="help-item">
                <h3>When will I be charged?</h3>
                <p>Your card is charged immediately when you complete your order.</p>
            </div>
            <div class="help-item">
                <h3>Can I split payment between cards?</h3>
                <p>Currently, we don't support split payments. You can use one card plus a gift card balance.</p>
            </div>
            <div class="help-item">
                <h3>Why was I charged more than the listed price?</h3>
                <p>The final total includes shipping costs and applicable taxes, which are calculated at checkout.</p>
            </div>
        </section>

        <div class="cta-section">
            <h2>Payment Questions?</h2>
            <p>Our support team can help with any payment concerns</p>
            <a href="/account.php?section=payment" class="btn btn-primary btn-lg">Manage Payment Methods</a>
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
