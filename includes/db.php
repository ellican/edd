<?php
/**
 * Database Connection - MariaDB/MySQL Only
 * E-Commerce Platform - Production Ready
 */
declare(strict_types=1);

if (!function_exists('db')) {
    function db(): ?PDO {
        static $pdo = null;
        if ($pdo instanceof PDO) return $pdo;

        // MariaDB/MySQL configuration only - no SQLite fallback
        $host     = defined('DB_HOST') ? DB_HOST : (getenv('DB_HOST') ?: 'localhost');
        $port     = defined('DB_PORT') ? DB_PORT : (getenv('DB_PORT') ?: '3306');
        $dbname   = defined('DB_NAME') ? DB_NAME : (getenv('DB_NAME') ?: 'ecommerce_platform');
        $user     = defined('DB_USER') ? DB_USER : (getenv('DB_USER') ?: 'fezamarket');
        $pass     = defined('DB_PASS') ? DB_PASS : (getenv('DB_PASS') ?: 'Tumukunde');
        $charset  = defined('DB_CHARSET') ? DB_CHARSET : (getenv('DB_CHARSET') ?: 'utf8mb4');

        $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset={$charset}";
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES {$charset} COLLATE {$charset}_unicode_ci",
        ];

        try {
            $pdo = new PDO($dsn, $user, $pass, $options);
            // Set MySQL-specific settings for optimal performance
            // NO_AUTO_CREATE_USER removed for MySQL 8.0+ compatibility
            $pdo->exec("SET SESSION sql_mode='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'");
        } catch (PDOException $e) {
            // Determine if we're in development mode
            $isDevelopment = (defined('APP_ENV') && APP_ENV === 'development') || 
                            (defined('APP_DEBUG') && APP_DEBUG === true) ||
                            (getenv('APP_ENV') === 'development') ||
                            (getenv('APP_DEBUG') === 'true');
            
            // Log detailed error information
            $errorDetails = [
                'message' => $e->getMessage(),
                'host' => $host,
                'port' => $port,
                'database' => $dbname,
                'user' => $user,
                'charset' => $charset,
                'code' => $e->getCode()
            ];
            
            // Create detailed log message (password excluded for security)
            $logMessage = sprintf(
                'MariaDB connection failed: %s | Host: %s | Port: %s | Database: %s | User: %s | Charset: %s | Code: %s',
                $e->getMessage(),
                $host,
                $port,
                $dbname,
                $user,
                $charset,
                $e->getCode()
            );
            error_log($logMessage);
            
            // In development mode, provide more detailed error message
            if ($isDevelopment) {
                $detailedMessage = sprintf(
                    "Database connection failed.\nHost: %s:%s\nDatabase: %s\nUser: %s\nError: %s",
                    $host,
                    $port,
                    $dbname,
                    $user,
                    $e->getMessage()
                );
                throw new Exception($detailedMessage);
            } else {
                // In production, show sanitized message
                throw new Exception("Database connection failed. Please check your MariaDB configuration.");
            }
        }
        
        return $pdo;
    }
}

if (!function_exists('db_transaction')) {
    function db_transaction(callable $fn) {
        $pdo = db();
        $pdo->beginTransaction();
        try {
            $result = $fn($pdo);
            $pdo->commit();
            return $result;
        } catch (Throwable $t) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $t;
        }
    }
}

if (!function_exists('db_ping')) {
    function db_ping(): bool {
        try {
            db()->query('SELECT 1')->fetchColumn();
            return true;
        } catch (Throwable $t) {
            return false;
        }
    }
}

if (!function_exists('getDatabase')) {
    /**
     * Legacy alias for db() function
     * Provides backward compatibility for code calling getDatabase()
     * 
     * @return PDO|null Database connection instance
     * @throws Exception If database connection fails
     */
    function getDatabase(): ?PDO {
        return db();
    }
}