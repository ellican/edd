    </div> <!-- End main-content -->
    
    <!-- eBay Style Footer -->
    <footer class="ebay-footer">
        <div class="footer-container">
            <!-- Main Footer Links -->
            <div class="footer-main">
                <!-- Buy Section -->
                <div class="footer-column">
                    <h3>Buy</h3>
                    <ul>
                        <li><a href="/register.php">Registration</a></li>
                        <li><a href="/help/buying.php">Bidding & buying help</a></li>
                        <li><a href="/stores.php">Stores</a></li>
                        <li><a href="/collections.php">Creator Collections</a></li>
                        <li><a href="/charity.php">FezaMarket for Charity</a></li>
                        <li><a href="/charity-shop.php">Charity Shop</a></li>
                        <li><a href="/seasonal-sales.php">Seasonal Sales and events</a></li>
                        <li><a href="/gift-cards.php">FezaMarket Gift Cards</a></li>
                        <li><a href="/closing-account.php">Closing account</a></li>
                    </ul>
                </div>
                
                <!-- Sell Section -->
                <div class="footer-column">
                    <h3>Sell</h3>
                    <ul>
                        <li><a href="<?php echo getSellingUrl(); ?>">Start selling</a></li>
                        <li><a href="/help/selling.php">How to sell</a></li>
                        <li><a href="/business-sellers.php">Business sellers</a></li>
                        <li><a href="/affiliates.php">Affiliates</a></li>
                    </ul>
                    
                    <h4>Tools & apps</h4>
                    <ul>
                        <li><a href="/developers.php">Developers</a></li>
                        <li><a href="/security-center.php">Security center</a></li>
                        <li><a href="/sitemap.php">Site map</a></li>
                    </ul>
                </div>
                
                <!-- FezaMarket companies Section -->
                <div class="footer-column">
                    <h3>FezaMarket companies</h3>
                    <ul>
                        <li><a href="/tcgplayer.php">TCGplayer</a></li>
                        <li><a href="/logistics.php">Feza Logistics</a></li>
                        <li><a href="/partnerships.php">Partnerships</a></li>
                    </ul>
                    
                    <h4>Stay connected</h4>
                    <ul class="social-links">
                        <li><a href="https://facebook.com/fezamarket" target="_blank"><i class="fab fa-facebook"></i> Facebook</a></li>
                        <li><a href="https://twitter.com/fezamarket" target="_blank"><i class="fab fa-twitter"></i> X (Twitter)</a></li>
                    </ul>
                </div>
                
                <!-- About FezaMarket Section -->
                <div class="footer-column">
                    <h3>About FezaMarket</h3>
                    <ul>
                        <li><a href="/company-info.php">Company info</a></li>
                        <li><a href="/news.php">News</a></li>
                        <li><a href="/investors.php">Investors</a></li>
                        <li><a href="/careers.php">Careers</a></li>
                        <li><a href="/diversity.php">Diversity & Inclusion</a></li>
                        <li><a href="/global-impact.php">Global Impact</a></li>
                        <li><a href="/government.php">Government relations</a></li>
                        <li><a href="/advertise.php">Advertise with us</a></li>
                        <li><a href="/policies.php">Policies</a></li>
                        <li><a href="/vero.php">Verified Rights Owner (VeRO) Program</a></li>
                        <li><a href="/eci-licenses.php">eCI Licenses</a></li>
                    </ul>
                </div>
                
                <!-- Help & Contact Section -->
                <div class="footer-column">
                    <h3>Help & Contact</h3>
                    <ul>
                        <li><a href="<?php echo getSellingUrl(); ?>">Seller Center</a></li>
                        <li><a href="/contact.php">Contact Us</a></li>
                        <li><a href="/returns.php">FezaMarket Returns</a></li>
                        <li><a href="/money-back.php">FezaMarket Money Back Guarantee</a></li>
                    </ul>
                    
                    <h4>Community</h4>
                    <ul>
                        <li><a href="/announcements.php">Announcements</a></li>
                        <li><a href="/community.php">FezaMarket Community</a></li>
                        <li><a href="/podcast.php">FezaMarket for Business Podcast</a></li>
                    </ul>
                    
                    <h4>FezaMarket Sites</h4>
                    <ul>
                        <li><a href="/regional-sites.php">International Sites</a></li>
                    </ul>
                    <div class="country-selector">
                        <select class="country-dropdown">
                            <option value="US" selected>🇺🇸 United States</option>
                            <option value="CA">🇨🇦 Canada</option>
                            <option value="UK">🇬🇧 United Kingdom</option>
                            <option value="AU">🇦🇺 Australia</option>
                        </select>
                    </div>
                </div>
            </div>
            
            <!-- Copyright and Legal Links -->
            <div class="footer-bottom">
                <div class="copyright-text">
                    Copyright � 1995-<?php echo date('Y'); ?> FezaMarket Inc. All Rights Reserved.
                </div>
                <div class="legal-links">
                    <a href="/accessibility.php">Accessibility</a>,
                    <a href="/user-agreement.php">User Agreement</a>,
                    <a href="/privacy.php">Privacy</a>,
                    <a href="/consumer-health-data.php">Consumer Health Data</a>,
                    <a href="/payments-terms.php">Payments Terms of Use</a>,
                    <a href="/cookies.php">Cookies</a>,
                    <a href="/ca-privacy-notice.php">CA Privacy Notice</a>,
                    <a href="/your-privacy-choices.php">Your Privacy Choices <i class="fas fa-shield-alt"></i></a> and
                    <a href="/adchoice.php">AdChoice <i class="fas fa-info-circle"></i></a>
                </div>
            </div>
        </div>
    </footer>

    <style>
        .ebay-footer {
            background-color: #f7f7f7;
            border-top: 1px solid #e5e5e5;
            margin-top: 2rem;
            padding: 2rem 0 1rem;
            font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif;
        }
        
        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .footer-main {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 2rem;
            margin-bottom: 2rem;
        }
        
        .footer-column h3 {
            color: #333;
            font-size: 16px;
            font-weight: 600;
            margin: 0 0 1rem 0;
            border: none;
        }
        
        .footer-column h4 {
            color: #333;
            font-size: 14px;
            font-weight: 600;
            margin: 1.5rem 0 0.5rem 0;
            border: none;
        }
        
        .footer-column ul {
            list-style: none;
            padding: 0;
            margin: 0 0 1rem 0;
        }
        
        .footer-column li {
            margin: 0 0 0.5rem 0;
        }
        
        .footer-column a {
            color: #666;
            text-decoration: none;
            font-size: 13px;
            line-height: 1.4;
            transition: color 0.2s;
        }
        
        .footer-column a:hover {
            color: #0654ba;
            text-decoration: underline;
        }
        
        .social-links a {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .social-links i {
            font-size: 14px;
        }
        
        .country-selector {
            margin-top: 1rem;
        }
        
        .country-dropdown {
            background: white;
            border: 1px solid #ccc;
            border-radius: 4px;
            padding: 8px 12px;
            font-size: 13px;
            color: #333;
            width: 100%;
            max-width: 200px;
            cursor: pointer;
        }
        
        .footer-bottom {
            border-top: 1px solid #e5e5e5;
            padding-top: 1rem;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: flex-start;
            gap: 1rem;
        }
        
        .copyright-text {
            color: #666;
            font-size: 12px;
            font-weight: 400;
        }
        
        .legal-links {
            color: #666;
            font-size: 12px;
            line-height: 1.4;
        }
        
        .legal-links a {
            color: #0654ba;
            text-decoration: none;
        }
        
        .legal-links a:hover {
            text-decoration: underline;
        }
        
        /* Mobile Responsive */
        @media (max-width: 1024px) {
            .footer-main {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        
        @media (max-width: 768px) {
            .footer-main {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .footer-bottom {
                flex-direction: column;
                align-items: flex-start;
            }
        }
        
        @media (max-width: 480px) {
            .footer-main {
                grid-template-columns: 1fr;
            }
        }
        
        /* Mobile Bottom Navigation Bar - eBay Style */
        .mobile-bottom-nav {
            display: none; /* Hidden by default, shown on mobile */
        }
        
        /* Mobile Search Overlay */
        .mobile-search-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: white;
            z-index: 2000;
            display: none;
            flex-direction: column;
        }
        
        .mobile-search-overlay.active {
            display: flex;
        }
        
        .mobile-search-header {
            display: flex;
            align-items: center;
            padding: 12px 16px;
            border-bottom: 1px solid #e5e5e5;
            gap: 12px;
            background: white;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        .mobile-search-close {
            background: none;
            border: none;
            font-size: 20px;
            color: #333;
            cursor: pointer;
            padding: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .mobile-search-form {
            flex: 1;
            display: flex;
            align-items: center;
            background: #f7f7f7;
            border-radius: 24px;
            border: 1px solid #ddd;
            overflow: hidden;
        }
        
        .mobile-search-input {
            flex: 1;
            border: none;
            background: transparent;
            padding: 12px 16px;
            font-size: 16px;
            outline: none;
        }
        
        .mobile-search-submit {
            background: none;
            border: none;
            padding: 12px 16px;
            color: #0654ba;
            font-size: 18px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .mobile-search-suggestions {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
        }
        
        .mobile-search-section {
            margin-bottom: 24px;
        }
        
        .mobile-search-section h3 {
            font-size: 14px;
            color: #666;
            margin-bottom: 12px;
            font-weight: 600;
        }
        
        .mobile-search-tag-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        
        .mobile-search-tag {
            display: inline-block;
            padding: 8px 16px;
            background: #f0f0f0;
            border-radius: 20px;
            text-decoration: none;
            color: #333;
            font-size: 14px;
            transition: background 0.2s ease;
        }
        
        .mobile-search-tag:hover {
            background: #e0e0e0;
        }
        
        @media (max-width: 768px) {
            .mobile-bottom-nav {
                display: flex;
                position: fixed;
                bottom: 0;
                left: 0;
                right: 0;
                background: white;
                border-top: 1px solid #e5e5e5;
                justify-content: space-around;
                align-items: center;
                padding: 8px 0 6px;
                z-index: 1000;
                box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
                transition: transform 0.3s ease;
            }
            
            /* Hide bottom nav when scrolling down */
            .mobile-bottom-nav.hide {
                transform: translateY(100%);
            }
            
            .mobile-bottom-nav-item {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                text-decoration: none;
                color: #333;
                font-size: 10px;
                min-width: 60px;
                padding: 4px 8px;
                transition: color 0.2s ease;
                touch-action: manipulation;
                position: relative;
            }
            
            .mobile-bottom-nav-item:hover,
            .mobile-bottom-nav-item.active {
                color: #0654ba;
            }
            
            .mobile-bottom-nav-icon {
                font-size: 22px;
                margin-bottom: 2px;
            }
            
            .mobile-bottom-nav-label {
                font-weight: 400;
                white-space: nowrap;
            }
            
            .mobile-bottom-nav-item.active .mobile-bottom-nav-label {
                font-weight: 600;
            }
            
            .mobile-bottom-nav-icon-wrapper {
                position: relative;
                display: inline-block;
            }
            
            .mobile-bottom-nav-badge {
                position: absolute;
                top: -5px;
                right: -8px;
                background-color: #e53238;
                color: white;
                border-radius: 10px;
                min-width: 18px;
                height: 18px;
                font-size: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 600;
                padding: 0 4px;
            }
            
            /* Add padding to body to prevent content from being hidden behind bottom nav */
            body {
                padding-bottom: 60px;
            }
            
            /* Adjust footer padding on mobile */
            .ebay-footer {
                margin-bottom: 60px;
            }
        }
    </style>

    <!-- JavaScript Libraries -->
    <script src="/js/jquery-shim.js"></script>
    <script src="/js/fezamarket.js"></script>
    
    <!-- Feza AI Widget -->
    <?php include __DIR__ . '/feza-ai-widget.php'; ?>
    
    <script>
        $(document).ready(function() {
            // CSRF token for AJAX requests
            $.ajaxSetup({
                beforeSend: function(xhr, settings) {
                    if (!/^(GET|HEAD|OPTIONS|TRACE)$/i.test(settings.type) && !this.crossDomain) {
                        const token = $('meta[name="csrf-token"]').attr('content');
                        if (token) {
                            xhr.setRequestHeader("X-CSRF-TOKEN", token);
                        }
                    }
                }
            });
            
            // Auto-hide flash messages
            $('.alert').each(function() {
                const alert = $(this);
                setTimeout(function() {
                    alert.fadeOut();
                }, 5000);
            });
            
            // Add active class to current page nav link
            const currentPath = window.location.pathname;
            const navLinks = document.querySelectorAll('.nav-links a');
            
            navLinks.forEach(link => {
                const linkPath = new URL(link.href).pathname;
                if (linkPath === currentPath || (currentPath.startsWith('/category') && link.href.includes('cat='))) {
                    link.classList.add('active');
                }
            });
        });
    </script>

    <!-- Mobile Search Overlay -->
    <div id="mobileSearchOverlay" class="mobile-search-overlay">
        <div class="mobile-search-header">
            <button id="mobileSearchClose" class="mobile-search-close" aria-label="Close search">
                <i class="fas fa-arrow-left"></i>
            </button>
            <form action="/search.php" method="GET" class="mobile-search-form" id="mobileSearchForm">
                <input 
                    type="text" 
                    name="q" 
                    id="mobileSearchInput" 
                    class="mobile-search-input" 
                    placeholder="Search for anything..."
                    autocomplete="off"
                >
                <button type="submit" class="mobile-search-submit">
                    <i class="fas fa-search"></i>
                </button>
            </form>
        </div>
        <div class="mobile-search-suggestions" id="mobileSearchSuggestions">
            <!-- Popular searches or recent searches can go here -->
            <div class="mobile-search-section">
                <h3>Popular Searches</h3>
                <div class="mobile-search-tag-list">
                    <a href="/search.php?q=electronics" class="mobile-search-tag">Electronics</a>
                    <a href="/search.php?q=fashion" class="mobile-search-tag">Fashion</a>
                    <a href="/search.php?q=home+decor" class="mobile-search-tag">Home Decor</a>
                    <a href="/search.php?q=sports" class="mobile-search-tag">Sports</a>
                    <a href="/search.php?q=books" class="mobile-search-tag">Books</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Mobile Bottom Navigation Bar (eBay-style) -->
    <nav class="mobile-bottom-nav" id="mobileBottomNav">
        <a href="/" class="mobile-bottom-nav-item <?php echo basename($_SERVER['PHP_SELF']) === 'index.php' ? 'active' : ''; ?>">
            <i class="fas fa-home mobile-bottom-nav-icon"></i>
            <span class="mobile-bottom-nav-label">Home</span>
        </a>
        <a href="/account.php" class="mobile-bottom-nav-item <?php echo basename($_SERVER['PHP_SELF']) === 'account.php' ? 'active' : ''; ?>">
            <i class="fas fa-user mobile-bottom-nav-icon"></i>
            <span class="mobile-bottom-nav-label">My Feza</span>
        </a>
        <a href="/search.php" class="mobile-bottom-nav-item <?php echo basename($_SERVER['PHP_SELF']) === 'search.php' ? 'active' : ''; ?>" id="mobileBottomNavSearch">
            <i class="fas fa-search mobile-bottom-nav-icon"></i>
            <span class="mobile-bottom-nav-label">Search</span>
        </a>
        <a href="/messages.php" class="mobile-bottom-nav-item <?php echo basename($_SERVER['PHP_SELF']) === 'messages.php' ? 'active' : ''; ?>">
            <div class="mobile-bottom-nav-icon-wrapper">
                <i class="fas fa-envelope mobile-bottom-nav-icon"></i>
                <?php
                // Show badge if user has unread messages
                if (Session::isLoggedIn()) {
                    try {
                        $db = db();
                        $stmt = $db->prepare("SELECT COUNT(*) as count FROM messages WHERE recipient_id = ? AND is_read = 0");
                        $stmt->execute([Session::getUserId()]);
                        $result = $stmt->fetch();
                        $unreadCount = $result['count'] ?? 0;
                        if ($unreadCount > 0) {
                            echo '<span class="mobile-bottom-nav-badge">' . min($unreadCount, 99) . '</span>';
                        }
                    } catch (Exception $e) {
                        // Silently fail if messages table doesn't exist
                    }
                }
                ?>
            </div>
            <span class="mobile-bottom-nav-label">Inbox</span>
        </a>
        <?php
        $userRole = getCurrentUserRole();
        $isSellerOrAdmin = $userRole === 'seller' || $userRole === 'admin';
        $sellingUrl = Session::isLoggedIn() && $isSellerOrAdmin ? getSellingUrl() : '/sell.php';
        ?>
        <a href="<?php echo $sellingUrl; ?>" class="mobile-bottom-nav-item <?php echo strpos($_SERVER['PHP_SELF'], 'sell') !== false || strpos($_SERVER['PHP_SELF'], 'seller') !== false ? 'active' : ''; ?>">
            <i class="fas fa-tag mobile-bottom-nav-icon"></i>
            <span class="mobile-bottom-nav-label">Selling</span>
        </a>
    </nav>

    <script>
        // Mobile bottom navigation scroll behavior - only on mobile devices
        let lastBottomNavScrollTop = 0;
        let bottomNavScrollThreshold = 5; // Minimum scroll distance to trigger
        let bottomNavTicking = false;
        
        function handleBottomNavScroll() {
            // Check if mobile - if not, skip
            if (window.innerWidth > 768) return;
            
            const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            const bottomNav = document.getElementById('mobileBottomNav');
            
            if (!bottomNav) {
                bottomNavTicking = false;
                return;
            }
            
            // Only trigger if scroll is beyond threshold
            if (Math.abs(scrollTop - lastBottomNavScrollTop) < bottomNavScrollThreshold) {
                bottomNavTicking = false;
                return;
            }
            
            if (scrollTop > lastBottomNavScrollTop && scrollTop > 50) {
                // Scrolling down - hide bottom nav
                bottomNav.classList.add('hide');
            } else {
                // Scrolling up - show bottom nav
                bottomNav.classList.remove('hide');
            }
            
            lastBottomNavScrollTop = scrollTop <= 0 ? 0 : scrollTop;
            bottomNavTicking = false;
        }
        
        window.addEventListener('scroll', function() {
            if (!bottomNavTicking) {
                window.requestAnimationFrame(handleBottomNavScroll);
                bottomNavTicking = true;
            }
        });
        
        // Handle bottom navigation search click on product pages
        (function() {
            const searchNavItem = document.getElementById('mobileBottomNavSearch');
            const searchOverlay = document.getElementById('mobileSearchOverlay');
            const searchClose = document.getElementById('mobileSearchClose');
            const searchInput = document.getElementById('mobileSearchInput');
            
            if (searchNavItem && searchOverlay) {
                // Open search overlay when clicking search icon in bottom nav
                searchNavItem.addEventListener('click', function(e) {
                    e.preventDefault();
                    
                    // Open the search overlay
                    searchOverlay.classList.add('active');
                    document.body.style.overflow = 'hidden'; // Prevent background scrolling
                    
                    // Focus on the search input
                    setTimeout(function() {
                        if (searchInput) {
                            searchInput.focus();
                        }
                    }, 100);
                });
                
                // Close search overlay
                if (searchClose) {
                    searchClose.addEventListener('click', function(e) {
                        e.preventDefault();
                        searchOverlay.classList.remove('active');
                        document.body.style.overflow = ''; // Restore scrolling
                    });
                }
                
                // Close on overlay click (outside the search area)
                searchOverlay.addEventListener('click', function(e) {
                    if (e.target === searchOverlay) {
                        searchOverlay.classList.remove('active');
                        document.body.style.overflow = '';
                    }
                });
                
                // Handle escape key to close overlay
                document.addEventListener('keydown', function(e) {
                    if (e.key === 'Escape' && searchOverlay.classList.contains('active')) {
                        searchOverlay.classList.remove('active');
                        document.body.style.overflow = '';
                    }
                });
            }
        })();
    </script>

    <?php
    // Include floating shopping cart panel (available on all pages)
    if (file_exists(__DIR__ . '/../includes/floating-cart.php')) {
        include __DIR__ . '/../includes/floating-cart.php';
    }
    ?>

</body>
</html>