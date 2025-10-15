<?php
/**
 * Migration: Add notification templates for sponsored products
 * 
 * Adds notification templates for:
 * - Sponsored ad approval
 * - Sponsored ad rejection  
 * - Sponsored ad expiration
 */

return [
    'up' => "
        -- Insert notification templates for sponsored products
        INSERT INTO notification_templates (type, name, subject, body_template, enabled, created_at)
        VALUES 
        (
            'sponsored_ad_approved',
            'Sponsored Ad Approved',
            'Your Sponsored Ad is Now Live! 🎉',
            'Good news! Your sponsored ad for {{product_name}} has been approved and is now live.\n\nYour product will be featured prominently for the next 7 days, helping you reach more customers and boost sales.\n\nExpires: {{expires_date}}\n\nView your ad performance and manage your sponsored products in your marketing dashboard.',
            1,
            NOW()
        ),
        (
            'sponsored_ad_rejected',
            'Sponsored Ad Rejected',
            'Your Sponsored Ad Request Has Been Reviewed',
            'We regret to inform you that your sponsored ad request for {{product_name}} has been rejected.\n\nReason: {{rejection_reason}}\n\nIf you have questions or would like to submit a revised request, please contact our support team or visit your marketing dashboard.',
            1,
            NOW()
        ),
        (
            'sponsored_ad_expired',
            'Sponsored Ad Expired',
            'Your Sponsored Ad Has Ended',
            'Your 7-day sponsored ad for {{product_name}} has expired and is no longer actively promoted.\n\nWe hope the sponsorship helped increase your product visibility and sales!\n\nInterested in sponsoring this product again? Visit your marketing dashboard to create a new sponsored ad.',
            1,
            NOW()
        )
        ON DUPLICATE KEY UPDATE type = type;
    ",
    'down' => "
        DELETE FROM notification_templates 
        WHERE type IN ('sponsored_ad_approved', 'sponsored_ad_rejected', 'sponsored_ad_expired');
    "
];
