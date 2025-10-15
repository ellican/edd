<?php
require_once __DIR__ . '/../includes/init.php';
includeHeader('How to Shop - FezaMarket Help');
?>

<div class="container">
    <div class="help-header">
        <h1>How to Shop on FezaMarket</h1>
        <p>Your complete guide to shopping on our platform</p>
    </div>

    <div class="help-content">
        <section class="help-section">
            <h2>Shopping Made Easy</h2>
            <div class="steps">
                <div class="step">
                    <div class="step-number">1</div>
                    <h3>Browse</h3>
                    <p>Explore categories or use search to find what you need.</p>
                </div>
                <div class="step">
                    <div class="step-number">2</div>
                    <h3>Compare</h3>
                    <p>Check reviews, ratings, and compare prices from different sellers.</p>
                </div>
                <div class="step">
                    <div class="step-number">3</div>
                    <h3>Add to Cart</h3>
                    <p>Select quantity and any options, then add to your cart.</p>
                </div>
                <div class="step">
                    <div class="step-number">4</div>
                    <h3>Checkout</h3>
                    <p>Review cart, enter shipping info, and complete payment.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Finding Products</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>🔍 Search Bar</h3>
                    <p>Enter keywords to find specific products. Use filters to narrow results by price, brand, rating, and more.</p>
                </div>
                <div class="help-item">
                    <h3>📂 Categories</h3>
                    <p>Browse by category from the navigation menu. Each category has subcategories for easier navigation.</p>
                </div>
                <div class="help-item">
                    <h3>🏷️ Deals & Promotions</h3>
                    <p>Check our Deals page for current sales, clearance items, and special offers.</p>
                </div>
                <div class="help-item">
                    <h3>⭐ Featured Products</h3>
                    <p>Discover trending and recommended items on the homepage.</p>
                </div>
            </div>
        </section>

        <section class="help-section">
            <h2>Understanding Product Listings</h2>
            <div class="help-item">
                <h3>📋 What to Look For</h3>
                <ul>
                    <li><strong>Product Photos:</strong> View multiple images to see all angles</li>
                    <li><strong>Description:</strong> Read full details about the product</li>
                    <li><strong>Price:</strong> Check if shipping is included</li>
                    <li><strong>Condition:</strong> New, used, refurbished, etc.</li>
                    <li><strong>Seller Info:</strong> Check seller ratings and reviews</li>
                    <li><strong>Shipping:</strong> Delivery time and cost</li>
                    <li><strong>Returns:</strong> Return policy and window</li>
                </ul>
            </div>
        </section>

        <section class="help-section">
            <h2>Smart Shopping Tips</h2>
            <div class="help-grid">
                <div class="help-item">
                    <h3>💡 Read Reviews</h3>
                    <p>Check what other buyers say about the product and seller before purchasing.</p>
                </div>
                <div class="help-item">
                    <h3>📊 Compare Prices</h3>
                    <p>Same item from multiple sellers? Compare prices and shipping costs.</p>
                </div>
                <div class="help-item">
                    <h3>❤️ Save for Later</h3>
                    <p>Add items to your wishlist to track price changes and availability.</p>
                </div>
                <div class="help-item">
                    <h3>🏷️ Use Coupons</h3>
                    <p>Look for promo codes and apply them at checkout for savings.</p>
                </div>
            </div>
        </section>

        <div class="cta-section">
            <h2>Ready to Start Shopping?</h2>
            <p>Explore thousands of products from trusted sellers</p>
            <a href="/products.php" class="btn btn-primary btn-lg">Browse Products</a>
            <a href="/deals.php" class="btn btn-outline btn-lg">View Deals</a>
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
