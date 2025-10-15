/**
 * Mobile Navigation Enhancement
 * Handles hamburger menu, touch interactions, and responsive behaviors
 */

(function() {
    'use strict';
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initMobileNav);
    } else {
        initMobileNav();
    }
    
    function initMobileNav() {
        // Create mobile menu toggle if it doesn't exist
        createMobileMenuToggle();
        
        // Initialize menu handlers
        initMenuToggle();
        
        // Handle window resize
        handleWindowResize();
        
        // Prevent horizontal scroll
        preventHorizontalScroll();
        
        // Fix iOS 100vh issue
        fixIOSViewportHeight();
        
        // Handle orientation changes
        handleOrientationChange();
    }
    
    /**
     * Create mobile menu toggle button
     */
    function createMobileMenuToggle() {
        // Check if toggle already exists
        if (document.querySelector('.mobile-menu-toggle')) {
            return;
        }
        
        // Find the main header
        const header = document.querySelector('.ebay-main-header-content, .main-header-content, .fezamarket-header');
        if (!header) return;
        
        // Create toggle button
        const toggle = document.createElement('button');
        toggle.className = 'mobile-menu-toggle';
        toggle.setAttribute('aria-label', 'Toggle navigation menu');
        toggle.setAttribute('aria-expanded', 'false');
        toggle.style.display = 'none'; // Hidden by default, shown via CSS on mobile
        toggle.innerHTML = '<i class="fas fa-bars"></i>';
        
        // Insert as first child or after logo
        const logo = header.querySelector('.ebay-logo, .fezamarket-logo');
        if (logo && logo.parentNode === header) {
            logo.after(toggle);
        } else {
            header.prepend(toggle);
        }
    }
    
    /**
     * Initialize menu toggle functionality
     */
    function initMenuToggle() {
        const toggle = document.querySelector('.mobile-menu-toggle');
        const nav = document.querySelector('.ebay-nav-section, .main-nav-center');
        
        if (!toggle || !nav) return;
        
        toggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const isOpen = nav.classList.contains('mobile-open');
            
            if (isOpen) {
                closeMenu();
            } else {
                openMenu();
            }
        });
        
        // Close menu when clicking outside
        document.addEventListener('click', function(e) {
            if (window.innerWidth <= 768) {
                const nav = document.querySelector('.ebay-nav-section, .main-nav-center');
                const toggle = document.querySelector('.mobile-menu-toggle');
                
                if (nav && nav.classList.contains('mobile-open')) {
                    if (!nav.contains(e.target) && !toggle.contains(e.target)) {
                        closeMenu();
                    }
                }
            }
        });
        
        // Close menu on escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeMenu();
            }
        });
        
        // Close menu when nav link is clicked
        if (nav) {
            nav.querySelectorAll('a').forEach(link => {
                link.addEventListener('click', function() {
                    if (window.innerWidth <= 768) {
                        setTimeout(closeMenu, 100);
                    }
                });
            });
        }
    }
    
    /**
     * Open mobile menu
     */
    function openMenu() {
        const toggle = document.querySelector('.mobile-menu-toggle');
        const nav = document.querySelector('.ebay-nav-section, .main-nav-center');
        
        if (!nav || !toggle) return;
        
        nav.classList.add('mobile-open');
        toggle.setAttribute('aria-expanded', 'true');
        toggle.innerHTML = '<i class="fas fa-times"></i>';
        
        // Prevent body scroll when menu is open
        document.body.style.overflow = 'hidden';
    }
    
    /**
     * Close mobile menu
     */
    function closeMenu() {
        const toggle = document.querySelector('.mobile-menu-toggle');
        const nav = document.querySelector('.ebay-nav-section, .main-nav-center');
        
        if (!nav || !toggle) return;
        
        nav.classList.remove('mobile-open');
        toggle.setAttribute('aria-expanded', 'false');
        toggle.innerHTML = '<i class="fas fa-bars"></i>';
        
        // Restore body scroll
        document.body.style.overflow = '';
    }
    
    /**
     * Handle window resize
     */
    function handleWindowResize() {
        let resizeTimer;
        
        window.addEventListener('resize', function() {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(function() {
                // Close menu if window is resized to desktop size
                if (window.innerWidth > 768) {
                    closeMenu();
                }
                
                // Fix viewport height
                fixIOSViewportHeight();
            }, 250);
        });
    }
    
    /**
     * Prevent horizontal scroll
     */
    function preventHorizontalScroll() {
        // Check for elements causing horizontal scroll
        function checkOverflow() {
            const body = document.body;
            const html = document.documentElement;
            
            const scrollWidth = Math.max(
                body.scrollWidth,
                html.scrollWidth
            );
            
            const clientWidth = html.clientWidth;
            
            if (scrollWidth > clientWidth) {
                console.warn('Horizontal scroll detected. Width:', scrollWidth, 'Viewport:', clientWidth);
                
                // Find overflowing elements
                const allElements = document.querySelectorAll('*');
                allElements.forEach(el => {
                    const rect = el.getBoundingClientRect();
                    if (rect.right > clientWidth || rect.left < 0) {
                        // Only log elements that significantly overflow
                        if (Math.abs(rect.right - clientWidth) > 10 || Math.abs(rect.left) > 10) {
                            console.warn('Overflowing element:', el, 'Right:', rect.right, 'Left:', rect.left);
                        }
                    }
                });
            }
        }
        
        // Check on load and after images load
        window.addEventListener('load', checkOverflow);
        
        // Recheck periodically for dynamically loaded content
        if (window.MutationObserver) {
            const observer = new MutationObserver(function() {
                clearTimeout(window.overflowCheckTimer);
                window.overflowCheckTimer = setTimeout(checkOverflow, 500);
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        }
    }
    
    /**
     * Fix iOS viewport height issue (100vh includes URL bar)
     */
    function fixIOSViewportHeight() {
        // Only apply on mobile devices
        if (window.innerWidth <= 768) {
            const vh = window.innerHeight * 0.01;
            document.documentElement.style.setProperty('--vh', `${vh}px`);
        }
    }
    
    /**
     * Handle orientation change
     */
    function handleOrientationChange() {
        window.addEventListener('orientationchange', function() {
            setTimeout(function() {
                fixIOSViewportHeight();
                closeMenu();
            }, 200);
        });
    }
    
    /**
     * Smooth scroll for anchor links
     */
    function initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                const href = this.getAttribute('href');
                if (href === '#' || href === '') return;
                
                const target = document.querySelector(href);
                if (target) {
                    e.preventDefault();
                    const offset = 80; // Account for sticky header
                    const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - offset;
                    
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                    
                    closeMenu();
                }
            });
        });
    }
    
    // Initialize smooth scroll
    initSmoothScroll();
    
    /**
     * Add touch-friendly interactions
     */
    function enhanceTouchInteractions() {
        // Add active state to buttons on touch
        const touchElements = document.querySelectorAll('.btn, button, a');
        
        touchElements.forEach(el => {
            el.addEventListener('touchstart', function() {
                this.classList.add('touch-active');
            });
            
            el.addEventListener('touchend', function() {
                setTimeout(() => {
                    this.classList.remove('touch-active');
                }, 300);
            });
        });
    }
    
    enhanceTouchInteractions();
    
    /**
     * Lazy load images on mobile
     */
    function initLazyLoading() {
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        if (img.dataset.src) {
                            img.src = img.dataset.src;
                            img.removeAttribute('data-src');
                        }
                        if (img.dataset.srcset) {
                            img.srcset = img.dataset.srcset;
                            img.removeAttribute('data-srcset');
                        }
                        observer.unobserve(img);
                    }
                });
            });
            
            document.querySelectorAll('img[data-src]').forEach(img => {
                imageObserver.observe(img);
            });
        }
    }
    
    initLazyLoading();
    
    /**
     * Debug: Log viewport info
     */
    if (window.location.search.includes('debug=1')) {
        console.log('Viewport width:', window.innerWidth);
        console.log('Viewport height:', window.innerHeight);
        console.log('Device pixel ratio:', window.devicePixelRatio);
        console.log('Touch support:', 'ontouchstart' in window);
        console.log('User agent:', navigator.userAgent);
    }
    
})();
