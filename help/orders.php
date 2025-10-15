<?php
require_once __DIR__ . '/../includes/init.php';
includeHeader('Orders & Shipping - FezaMarket Help');
?>

<div class="container">
    <div class="help-header">
        <h1>Orders & Shipping</h1>
        <p>Everything you need to know about ordering and shipping</p>
    </div>

    <div class="help-content">
        <section class="help-section">
            <h2>Placing an Order</h2>
            <div class="steps">
                <div class="step">
                    <div class="step-number">1</div>
                    <h3>Browse & Select</h3>
                    <p>Find products you love and add them to your cart.</p>
                </div>
                <div class="step">
                    <div class="step-number">2</div>
                    <h3>Review Cart</h3>
                    <p>Check items, quantities, and apply coupons if available.</p>
                </div>
                <div class="step">
                    <div class="step-number">3</div>
                    <h3>Checkout</h3>
                    <p>Enter shipping address and select delivery options.</p>
                </div>
                <div class="step">
                    <div class="step-number">4</div>
                    <h3>Payment</h3>
                    <p>Complete secure payment and receive order confirmation.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Shipping Options</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>📦 Standard Shipping</h3>
                    <p><strong>Delivery:</strong> 5-7 business days</p>
                    <p><strong>Cost:</strong> Calculated at checkout based on location</p>
                    <p>Best for non-urgent orders. Free shipping available on orders over $50.</p>
                </div>
                <div class="help-item">
                    <h3>⚡ Express Shipping</h3>
                    <p><strong>Delivery:</strong> 2-3 business days</p>
                    <p><strong>Cost:</strong> Additional fee applies</p>
                    <p>Faster delivery for time-sensitive orders.</p>
                </div>
                <div class="help-item">
                    <h3>🚀 Overnight Shipping</h3>
                    <p><strong>Delivery:</strong> 1 business day</p>
                    <p><strong>Cost:</strong> Premium rate</p>
                    <p>Next-day delivery for urgent needs. Order by 2 PM for next-day delivery.</p>
                </div>
                <div class="help-item">
                    <h3>🌍 International Shipping</h3>
                    <p><strong>Delivery:</strong> 10-20 business days</p>
                    <p><strong>Cost:</strong> Varies by destination</p>
                    <p>We ship to most countries worldwide. Customs fees may apply.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Order Tracking</h2>
            <div class="help-item">
                <h3>📍 Track Your Order</h3>
                <p>Once your order ships, you'll receive:</p>
                <ul>
                    <li>Shipping confirmation email</li>
                    <li>Tracking number</li>
                    <li>Estimated delivery date</li>
                    <li>Link to track your package</li>
                </ul>
                <p><strong>Track online:</strong> Go to "My Orders" in your account to view real-time tracking updates.</p>
            </div>
        </section>

        <section class="help-section">
            <h2>Order Status Explained</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>⏳ Processing</h3>
                    <p>Your order has been received and is being prepared for shipment.</p>
                </div>
                <div class="help-item">
                    <h3>📦 Shipped</h3>
                    <p>Your order is on its way! Check tracking for delivery updates.</p>
                </div>
                <div class="help-item">
                    <h3>🚚 In Transit</h3>
                    <p>Your package is moving through the shipping network.</p>
                </div>
                <div class="help-item">
                    <h3>✅ Delivered</h3>
                    <p>Your order has been delivered to the specified address.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Delivery Issues</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>📦 Package Not Received</h3>
                    <p>If tracking shows delivered but you didn't receive it:</p>
                    <ul>
                        <li>Check with neighbors or building management</li>
                        <li>Look in alternate delivery locations</li>
                        <li>Wait 24 hours (carrier may have marked early)</li>
                        <li>Contact us for assistance</li>
                    </ul>
                </div>
                <div class="help-item">
                    <h3>⏰ Delayed Delivery</h3>
                    <p>If your order is delayed:</p>
                    <ul>
                        <li>Check tracking for updates</li>
                        <li>Weather and holidays may cause delays</li>
                        <li>Contact carrier directly for specifics</li>
                        <li>We'll help resolve any issues</li>
                    </ul>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Frequently Asked Questions</h2>
            <div class="help-item">
                <h3>Can I change my shipping address after ordering?</h3>
                <p>Contact us immediately if you need to change your address. We can update it if the order hasn't shipped yet.</p>
            </div>
            <div class="help-item">
                <h3>Do you offer free shipping?</h3>
                <p>Yes! Free standard shipping on orders over $50. Premium members get free shipping on all orders.</p>
            </div>
            <div class="help-item">
                <h3>Can I track multiple orders at once?</h3>
                <p>Yes, view all your active orders in the "My Orders" section of your account.</p>
            </div>
            <div class="help-item">
                <h3>What if I need my order urgently?</h3>
                <p>Select Express or Overnight shipping at checkout for faster delivery.</p>
            </div>
        </section>

        <div class="cta-section">
            <h2>Need Help with Your Order?</h2>
            <p>Our team is ready to assist you</p>
            <a href="/account.php?section=orders" class="btn btn-primary btn-lg">Track My Orders</a>
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
.help-item ul{margin:15px 0;padding-left:25px}
.help-item li{margin-bottom:8px;color:#374151}
.cta-section{text-align:center;padding:40px;background:linear-gradient(135deg,#f9fafb 0%,#e5e7eb 100%);border-radius:12px;margin-top:40px}
.cta-section h2{margin-bottom:20px}
.btn-lg{padding:15px 40px;font-size:18px}
@media (max-width:768px){.help-grid,.steps{grid-template-columns:1fr}}
</style>

<?php includeFooter(); ?>
