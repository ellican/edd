/**
 * Checkout Page - Payment Processing
 * Handles Stripe payment integration for the complete checkout flow
 */

(function() {
    'use strict';

    // Get Stripe publishable key from window
    const stripePublishableKey = window.STRIPE_PUBLISHABLE_KEY;
    if (!stripePublishableKey) {
        console.error('Stripe publishable key not configured');
        return;
    }

    // Initialize Stripe
    const stripe = Stripe(stripePublishableKey);
    const elements = stripe.elements();

    // Stripe Elements styling
    const elementStyles = {
        base: {
            fontSize: '16px',
            color: '#32325d',
            fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            '::placeholder': {
                color: '#aab7c4'
            }
        },
        invalid: {
            color: '#fa755a',
            iconColor: '#fa755a'
        }
    };

    // Create separate card elements
    const cardNumberElement = elements.create('cardNumber', {
        style: elementStyles,
        placeholder: '1234 5678 9012 3456'
    });

    const cardExpiryElement = elements.create('cardExpiry', {
        style: elementStyles
    });

    const cardCvcElement = elements.create('cardCvc', {
        style: elementStyles
    });

    // Mount card elements to their containers
    cardNumberElement.mount('#stripe-card-number');
    cardExpiryElement.mount('#stripe-card-expiry');
    cardCvcElement.mount('#stripe-card-cvc');

    // Handle real-time validation errors
    const displayError = document.getElementById('stripe-card-errors');
    
    function handleCardError(event) {
        if (event.error) {
            displayError.textContent = event.error.message;
        } else {
            displayError.textContent = '';
        }
    }

    cardNumberElement.on('change', handleCardError);
    cardExpiryElement.on('change', handleCardError);
    cardCvcElement.on('change', handleCardError);

    // Get form elements
    const form = document.getElementById('checkout-form');
    const submitButton = document.getElementById('submit-checkout');
    const buttonText = document.getElementById('button-text');
    const spinner = document.getElementById('button-spinner');
    const paymentMessage = document.getElementById('payment-message');

    // Handle checkout submission
    submitButton?.addEventListener('click', async function(e) {
        e.preventDefault();
        
        // Validate form
        if (!validateCheckoutForm()) {
            return;
        }
        
        // Disable submit button to prevent double submission
        submitButton.disabled = true;
        buttonText.style.display = 'none';
        spinner.style.display = 'inline-block';
        paymentMessage.innerHTML = '';
        
        try {
            // Get form data
            const formData = getCheckoutFormData();
            
            // Step 1: Create PaymentIntent on server
            console.log('Creating payment intent...');
            const response = await fetch('/api/create-payment-intent.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': getCsrfToken()
                },
                body: JSON.stringify(formData)
            });
            
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({ error: 'Server error' }));
                throw new Error(errorData.error || 'Failed to create payment intent');
            }
            
            const data = await response.json();
            
            if (!data.success || !data.clientSecret) {
                throw new Error(data.error || 'Invalid server response');
            }
            
            console.log('PaymentIntent created:', data.paymentIntentId);
            
            // Step 2: Confirm payment with Stripe
            console.log('Confirming payment...');
            const {error, paymentIntent} = await stripe.confirmCardPayment(
                data.clientSecret,
                {
                    payment_method: {
                        card: cardNumberElement,
                        billing_details: formData.billing_address
                    },
                    shipping: formData.shipping_address
                }
            );
            
            if (error) {
                // Show error to customer
                console.error('Payment error:', error);
                
                // Handle specific error types
                let errorMessage = error.message;
                if (error.code === 'card_declined') {
                    errorMessage = 'Your card was declined. Please try a different payment method.';
                } else if (error.code === 'insufficient_funds') {
                    errorMessage = 'Your card has insufficient funds. Please try a different card.';
                } else if (error.code === 'authentication_required') {
                    errorMessage = 'Authentication required. Please complete the verification.';
                }
                
                throw new Error(errorMessage);
            }
            
            // Payment successful!
            console.log('Payment successful:', paymentIntent.id);
            
            // Get order reference from the API response
            if (!data.orderRef) {
                console.error('Order reference missing from API response');
                throw new Error('Order reference not available. Please contact support with payment ID: ' + paymentIntent.id);
            }
            
            const orderRef = data.orderRef;
            
            // Show success message briefly
            paymentMessage.innerHTML = '<div class="alert alert-success">✓ Payment successful! Redirecting...</div>';
            
            // Redirect to confirmation page with order reference
            setTimeout(() => {
                window.location.href = '/order-confirmation.php?ref=' + orderRef;
            }, 1000);
            
        } catch (error) {
            // Show error message
            console.error('Checkout error:', error);
            paymentMessage.innerHTML = '<div class="alert alert-error">' + 
                (error.message || 'An error occurred during checkout. Please try again.') + 
                '</div>';
            
            // Re-enable submit button
            submitButton.disabled = false;
            buttonText.style.display = 'inline';
            spinner.style.display = 'none';
        }
    });

    // Validate checkout form
    function validateCheckoutForm() {
        const requiredFields = [
            'customer_email',
            'customer_phone',
            'shipping_first_name',
            'shipping_last_name',
            'shipping_address_line1',
            'shipping_city',
            'shipping_state',
            'shipping_postal_code',
            'shipping_country',
            'shipping_phone'
        ];
        
        // Check if billing is same as shipping
        const sameAsShipping = document.getElementById('same_as_shipping')?.checked;
        
        // Add billing fields if not same as shipping
        if (!sameAsShipping) {
            requiredFields.push(
                'billing_first_name',
                'billing_last_name',
                'billing_address_line1',
                'billing_city',
                'billing_state',
                'billing_postal_code',
                'billing_country',
                'billing_phone'
            );
        }
        
        // Validate each required field
        for (const fieldName of requiredFields) {
            const field = document.getElementById(fieldName);
            if (!field || !field.value.trim()) {
                paymentMessage.innerHTML = '<div class="alert alert-error">Please fill in all required fields.</div>';
                
                // Focus the first invalid field
                field?.focus();
                return false;
            }
        }
        
        // Validate email format
        const email = document.getElementById('customer_email').value;
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            paymentMessage.innerHTML = '<div class="alert alert-error">Please enter a valid email address.</div>';
            document.getElementById('customer_email').focus();
            return false;
        }
        
        return true;
    }

    // Get checkout form data
    function getCheckoutFormData() {
        const sameAsShipping = document.getElementById('same_as_shipping')?.checked;
        
        // Build shipping address
        const shippingAddress = {
            name: document.getElementById('shipping_first_name').value + ' ' + 
                  document.getElementById('shipping_last_name').value,
            phone: document.getElementById('shipping_phone').value,
            address: {
                line1: document.getElementById('shipping_address_line1').value,
                line2: document.getElementById('shipping_address_line2')?.value || undefined,
                city: document.getElementById('shipping_city').value,
                state: document.getElementById('shipping_state').value,
                postal_code: document.getElementById('shipping_postal_code').value,
                country: document.getElementById('shipping_country').value
            }
        };
        
        // Build billing address
        let billingAddress;
        if (sameAsShipping) {
            // Use shipping address for billing
            billingAddress = {
                name: shippingAddress.name,
                email: document.getElementById('customer_email').value,
                phone: shippingAddress.phone,
                address: { ...shippingAddress.address }
            };
        } else {
            billingAddress = {
                name: document.getElementById('billing_first_name').value + ' ' + 
                      document.getElementById('billing_last_name').value,
                email: document.getElementById('customer_email').value,
                phone: document.getElementById('billing_phone').value,
                address: {
                    line1: document.getElementById('billing_address_line1').value,
                    line2: document.getElementById('billing_address_line2')?.value || undefined,
                    city: document.getElementById('billing_city').value,
                    state: document.getElementById('billing_state').value,
                    postal_code: document.getElementById('billing_postal_code').value,
                    country: document.getElementById('billing_country').value
                }
            };
        }
        
        return {
            billing_address: billingAddress,
            shipping_address: shippingAddress,
            shipping_method: document.getElementById('selected_shipping_method').value,
            shipping_cost: parseFloat(document.getElementById('selected_shipping_cost').value),
            coupon_code: document.getElementById('applied_coupon_code').value || null,
            gift_card_code: document.getElementById('applied_gift_card_code').value || null,
            save_for_future: document.getElementById('save_card')?.checked || false,
            save_address: document.getElementById('save_address')?.checked || false
        };
    }
})();
