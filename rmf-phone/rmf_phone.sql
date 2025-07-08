-- RMF Phone Database Structure

-- Phone Users Table
CREATE TABLE IF NOT EXISTS `rmf_phone_users` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `phone_number` varchar(10) NOT NULL,
    `pin_code` varchar(4) DEFAULT NULL,
    `battery` int(11) DEFAULT 100,
    `wallpaper` varchar(255) DEFAULT 'default',
    `ringtone` varchar(255) DEFAULT 'default',
    `notification_sound` varchar(255) DEFAULT 'default',
    `is_airplane_mode` tinyint(1) DEFAULT 0,
    `is_silent_mode` tinyint(1) DEFAULT 0,
    `last_seen` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    UNIQUE KEY `citizenid` (`citizenid`),
    UNIQUE KEY `phone_number` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Contacts Table
CREATE TABLE IF NOT EXISTS `rmf_phone_contacts` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `name` varchar(100) NOT NULL,
    `number` varchar(10) NOT NULL,
    `photo` varchar(255) DEFAULT NULL,
    `favorite` tinyint(1) DEFAULT 0,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Messages Table
CREATE TABLE IF NOT EXISTS `rmf_phone_messages` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `sender` varchar(10) NOT NULL,
    `receiver` varchar(10) NOT NULL,
    `message` text NOT NULL,
    `attachments` text DEFAULT NULL,
    `read_status` tinyint(1) DEFAULT 0,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `sender` (`sender`),
    KEY `receiver` (`receiver`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Call History Table
CREATE TABLE IF NOT EXISTS `rmf_phone_calls` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `caller` varchar(10) NOT NULL,
    `receiver` varchar(10) NOT NULL,
    `duration` int(11) DEFAULT 0,
    `call_type` enum('incoming','outgoing','missed') NOT NULL,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Photos Table
CREATE TABLE IF NOT EXISTS `rmf_phone_photos` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `url` varchar(500) NOT NULL,
    `caption` varchar(255) DEFAULT NULL,
    `location` varchar(255) DEFAULT NULL,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Notes Table
CREATE TABLE IF NOT EXISTS `rmf_phone_notes` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `title` varchar(100) NOT NULL,
    `content` text NOT NULL,
    `color` varchar(7) DEFAULT '#FFEB3B',
    `created_at` timestamp DEFAULT current_timestamp(),
    `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Birdy (Twitter) Table
CREATE TABLE IF NOT EXISTS `rmf_phone_tweets` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `username` varchar(50) NOT NULL,
    `display_name` varchar(100) NOT NULL,
    `avatar` varchar(255) DEFAULT NULL,
    `verified` tinyint(1) DEFAULT 0,
    `content` varchar(280) NOT NULL,
    `attachments` text DEFAULT NULL,
    `likes` int(11) DEFAULT 0,
    `retweets` int(11) DEFAULT 0,
    `replies` int(11) DEFAULT 0,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Instapic (Instagram) Table
CREATE TABLE IF NOT EXISTS `rmf_phone_instapic` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `username` varchar(50) NOT NULL,
    `display_name` varchar(100) NOT NULL,
    `avatar` varchar(255) DEFAULT NULL,
    `verified` tinyint(1) DEFAULT 0,
    `image` varchar(500) NOT NULL,
    `caption` text DEFAULT NULL,
    `likes` int(11) DEFAULT 0,
    `comments` int(11) DEFAULT 0,
    `location` varchar(255) DEFAULT NULL,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Trendy (TikTok) Table
CREATE TABLE IF NOT EXISTS `rmf_phone_trendy` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `username` varchar(50) NOT NULL,
    `display_name` varchar(100) NOT NULL,
    `avatar` varchar(255) DEFAULT NULL,
    `verified` tinyint(1) DEFAULT 0,
    `video` varchar(500) NOT NULL,
    `caption` varchar(150) DEFAULT NULL,
    `sound` varchar(255) DEFAULT NULL,
    `likes` int(11) DEFAULT 0,
    `comments` int(11) DEFAULT 0,
    `shares` int(11) DEFAULT 0,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Yellow Pages Table
CREATE TABLE IF NOT EXISTS `rmf_phone_yellowpages` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `title` varchar(100) NOT NULL,
    `description` text NOT NULL,
    `category` varchar(50) NOT NULL,
    `contact` varchar(10) NOT NULL,
    `price` decimal(10,2) DEFAULT NULL,
    `image` varchar(255) DEFAULT NULL,
    `active` tinyint(1) DEFAULT 1,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Crypto Table
CREATE TABLE IF NOT EXISTS `rmf_phone_crypto` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `crypto_type` varchar(10) NOT NULL,
    `amount` decimal(20,8) NOT NULL DEFAULT 0.00000000,
    `transactions` text DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_crypto` (`citizenid`, `crypto_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Racing Table
CREATE TABLE IF NOT EXISTS `rmf_phone_racing` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `creator` varchar(50) NOT NULL,
    `race_name` varchar(100) NOT NULL,
    `track_data` longtext NOT NULL,
    `buy_in` int(11) NOT NULL DEFAULT 0,
    `max_participants` int(11) NOT NULL DEFAULT 8,
    `participants` text DEFAULT NULL,
    `status` enum('waiting','active','finished','cancelled') DEFAULT 'waiting',
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `creator` (`creator`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Houses Table
CREATE TABLE IF NOT EXISTS `rmf_phone_houses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `house_id` varchar(50) NOT NULL,
    `address` varchar(255) NOT NULL,
    `price` int(11) NOT NULL,
    `for_sale` tinyint(1) DEFAULT 0,
    `keys` text DEFAULT NULL,
    `garage` tinyint(1) DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `house_id` (`house_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vehicles Table
CREATE TABLE IF NOT EXISTS `rmf_phone_vehicles` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `plate` varchar(8) NOT NULL,
    `vehicle` varchar(50) NOT NULL,
    `garage` varchar(50) DEFAULT NULL,
    `state` tinyint(1) DEFAULT 1,
    `fuel` int(11) DEFAULT 100,
    `engine` decimal(8,2) DEFAULT 1000.00,
    `body` decimal(8,2) DEFAULT 1000.00,
    `mods` longtext DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`),
    KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Invoices Table
CREATE TABLE IF NOT EXISTS `rmf_phone_invoices` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `sender` varchar(50) NOT NULL,
    `receiver` varchar(50) NOT NULL,
    `amount` decimal(10,2) NOT NULL,
    `description` varchar(255) NOT NULL,
    `due_date` date DEFAULT NULL,
    `status` enum('pending','paid','overdue','cancelled') DEFAULT 'pending',
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `sender` (`sender`),
    KEY `receiver` (`receiver`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Wenmo Transactions Table
CREATE TABLE IF NOT EXISTS `rmf_phone_wenmo` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `sender` varchar(50) NOT NULL,
    `receiver` varchar(50) NOT NULL,
    `amount` decimal(10,2) NOT NULL,
    `message` varchar(255) DEFAULT NULL,
    `status` enum('pending','completed','failed') DEFAULT 'pending',
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `sender` (`sender`),
    KEY `receiver` (`receiver`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- News Table
CREATE TABLE IF NOT EXISTS `rmf_phone_news` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `author` varchar(50) NOT NULL,
    `title` varchar(200) NOT NULL,
    `content` longtext NOT NULL,
    `image` varchar(255) DEFAULT NULL,
    `category` varchar(50) NOT NULL,
    `published` tinyint(1) DEFAULT 0,
    `views` int(11) DEFAULT 0,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `author` (`author`),
    KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Casino Table
CREATE TABLE IF NOT EXISTS `rmf_phone_casino` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `game_type` varchar(50) NOT NULL,
    `bet_amount` decimal(10,2) NOT NULL,
    `result` decimal(10,2) NOT NULL,
    `win` tinyint(1) NOT NULL,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- MEOS (Police) Table
CREATE TABLE IF NOT EXISTS `rmf_phone_meos` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `officer` varchar(50) NOT NULL,
    `search_type` varchar(50) NOT NULL,
    `search_data` text NOT NULL,
    `results` longtext DEFAULT NULL,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `officer` (`officer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Mail Table
CREATE TABLE IF NOT EXISTS `rmf_phone_mail` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `sender` varchar(100) NOT NULL,
    `subject` varchar(200) NOT NULL,
    `message` longtext NOT NULL,
    `attachments` text DEFAULT NULL,
    `read_status` tinyint(1) DEFAULT 0,
    `important` tinyint(1) DEFAULT 0,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Services Table
CREATE TABLE IF NOT EXISTS `rmf_phone_services` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `service_name` varchar(100) NOT NULL,
    `phone_number` varchar(10) NOT NULL,
    `description` text NOT NULL,
    `category` varchar(50) NOT NULL,
    `available_24_7` tinyint(1) DEFAULT 0,
    `active` tinyint(1) DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Default Services
INSERT IGNORE INTO `rmf_phone_services` (`service_name`, `phone_number`, `description`, `category`, `available_24_7`, `active`) VALUES
('Police Department', '911', 'Emergency police services', 'emergency', 1, 1),
('Emergency Medical Services', '911', 'Emergency medical services', 'emergency', 1, 1),
('Fire Department', '911', 'Emergency fire services', 'emergency', 1, 1),
('Taxi Service', '555-TAXI', 'Professional taxi service', 'transport', 1, 1),
('Mechanic Service', '555-MECH', 'Vehicle repair and towing', 'automotive', 0, 1),
('Real Estate Agency', '555-HOME', 'Buy and sell properties', 'real_estate', 0, 1),
('Bank Customer Service', '555-BANK', 'Banking support and services', 'financial', 0, 1);

-- Employment Table
CREATE TABLE IF NOT EXISTS `rmf_phone_employment` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `job_title` varchar(100) NOT NULL,
    `company` varchar(100) NOT NULL,
    `description` text NOT NULL,
    `requirements` text DEFAULT NULL,
    `salary` varchar(50) DEFAULT NULL,
    `contact` varchar(10) NOT NULL,
    `active` tinyint(1) DEFAULT 1,
    `created_at` timestamp DEFAULT current_timestamp(),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;