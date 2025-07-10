-- ==========================================
-- SK8 DATABASE MIGRATION SCRIPT
-- ==========================================
-- This file sets up the complete SK8 database schema
-- Run this script on a fresh PostgreSQL/Supabase instance

BEGIN;

-- Step 1: Create required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pgjwt";

-- Step 2: Create all tables
\i sk8_database_export.sql

-- Step 3: Insert sample data for development
INSERT INTO public.achievements (name, description, icon) VALUES 
('First Spot', 'Added your first skateboarding spot', '🎯'),
('Explorer', 'Visited 10 different spots', '🗺️'),
('Reviewer', 'Left 5 helpful reviews', '⭐'),
('Social Skater', 'Following 10 other skaters', '👥');

INSERT INTO public.tricks (name, description, difficulty) VALUES 
('Ollie', 'Basic jump trick - foundation of skateboarding', 'beginner'),
('Kickflip', 'Board flips 360° along its axis', 'intermediate'),
('Heelflip', 'Board flips backward along its axis', 'intermediate'),
('360 Flip', 'Combination of kickflip and shuvit', 'advanced'),
('Tre Flip', 'Another name for 360 flip', 'advanced'),
('Impossible', 'Board wraps around back foot', 'pro');

INSERT INTO public.daily_challenges (title, description, xp_reward, is_active, icon) VALUES 
('Visit a New Spot', 'Discover and check in at a spot you have never visited', 100, true, '📍'),
('Upload Photos', 'Take and upload 3 photos of different spots', 75, true, '📸'),
('Write a Review', 'Leave a detailed review for a spot', 50, true, '✍️'),
('Try a New Trick', 'Log a trick you have never attempted before', 125, true, '🛹'),
('Social Saturday', 'Follow 3 new skaters in the community', 80, true, '👋'),
('Spot Hunter', 'Find and add a new spot to the platform', 200, true, '🔍');

COMMIT;

-- Post-setup verification queries
SELECT 'Extensions installed:' as status, extname FROM pg_extension WHERE extname IN ('uuid-ossp', 'pgcrypto', 'postgis', 'pgjwt');
SELECT 'Tables created:' as status, COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
SELECT 'RLS policies:' as status, COUNT(*) as policy_count FROM pg_policies WHERE schemaname = 'public'; 