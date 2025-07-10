-- ==========================================
-- SK8 DATABASE EXPORT
-- Generated on: $(date)
-- Project: SK8 Skateboarding Platform
-- Database: Supabase PostgreSQL
-- ==========================================

-- This file contains the complete database schema for the SK8 skateboarding
-- platform including all tables, constraints, RLS policies, extensions,
-- and sample data structure.

-- ==========================================
-- EXTENSIONS
-- ==========================================

-- Required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pgjwt";
CREATE EXTENSION IF NOT EXISTS "supabase_vault";

-- ==========================================
-- SCHEMAS
-- ==========================================

-- Create public schema (already exists by default)
-- CREATE SCHEMA IF NOT EXISTS public;

-- ==========================================
-- TABLE DEFINITIONS
-- ==========================================

-- Table: achievements
-- Purpose: Store skateboarding achievements and milestones
CREATE TABLE public.achievements (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    description text,
    icon text,
    created_at timestamptz DEFAULT now(),
    CONSTRAINT achievements_pkey PRIMARY KEY (id)
);

-- Table: user_profiles
-- Purpose: Extended user profile information
CREATE TABLE public.user_profiles (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    first_name varchar(50),
    last_name varchar(50),
    display_name varchar(30),
    bio text,
    avatar_url text,
    preferences jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
    CONSTRAINT user_profiles_user_id_key UNIQUE (user_id)
);

-- Table: spots
-- Purpose: Skateboarding spots/locations
CREATE TABLE public.spots (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    type text CHECK (type IN ('street', 'park', 'bowl', 'vert', 'mini_ramp', 'transition', 'plaza', 'diy')),
    difficulty text CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'pro')),
    surface text CHECK (surface IN ('concrete', 'asphalt', 'wood', 'metal', 'marble', 'brick', 'tile')),
    features jsonb DEFAULT '{}'::jsonb,
    location geometry(Point, 4326),
    latitude double precision,
    longitude double precision,
    skateability_score double precision CHECK (skateability_score >= 0 AND skateability_score <= 10),
    technical_details jsonb DEFAULT '{}'::jsonb,
    verified boolean DEFAULT false,
    status text DEFAULT 'active'::text CHECK (status IN ('active', 'inactive', 'under_construction', 'demolished')),
    public boolean DEFAULT true,
    address text,
    created_by uuid NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CONSTRAINT spots_pkey PRIMARY KEY (id)
);

-- Table: collections
-- Purpose: User-created collections of spots
CREATE TABLE public.collections (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    icon text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CONSTRAINT collections_pkey PRIMARY KEY (id)
);

-- Table: collection_spots
-- Purpose: Many-to-many relationship between collections and spots
CREATE TABLE public.collection_spots (
    collection_id uuid NOT NULL,
    spot_id uuid NOT NULL,
    added_at timestamptz DEFAULT now(),
    CONSTRAINT collection_spots_pkey PRIMARY KEY (collection_id, spot_id),
    CONSTRAINT collection_spots_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE,
    CONSTRAINT collection_spots_spot_id_fkey FOREIGN KEY (spot_id) REFERENCES spots(id) ON DELETE CASCADE
);

-- Table: spot_images
-- Purpose: Images associated with spots
CREATE TABLE public.spot_images (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    spot_id uuid NOT NULL,
    user_id uuid NOT NULL,
    image_url text NOT NULL,
    is_primary boolean DEFAULT false,
    angle text CHECK (angle IN ('front', 'back', 'left', 'right', 'aerial', 'detail')),
    created_at timestamptz DEFAULT now(),
    CONSTRAINT spot_images_pkey PRIMARY KEY (id),
    CONSTRAINT spot_images_spot_id_fkey FOREIGN KEY (spot_id) REFERENCES spots(id) ON DELETE CASCADE
);

-- Table: spot_reviews
-- Purpose: User reviews and ratings for spots
CREATE TABLE public.spot_reviews (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    spot_id uuid NOT NULL,
    user_id uuid NOT NULL,
    rating double precision CHECK (rating >= 1 AND rating <= 5),
    comment text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    CONSTRAINT spot_reviews_pkey PRIMARY KEY (id),
    CONSTRAINT spot_reviews_spot_id_fkey FOREIGN KEY (spot_id) REFERENCES spots(id) ON DELETE CASCADE
);

-- Table: spot_analysis
-- Purpose: AI-powered analysis of spots
CREATE TABLE public.spot_analysis (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    spot_id uuid NOT NULL,
    type text,
    confidence double precision,
    features jsonb,
    surface_quality text,
    difficulty text,
    skateability_score double precision,
    suggested_tricks text[],
    created_at timestamptz DEFAULT now(),
    CONSTRAINT spot_analysis_pkey PRIMARY KEY (id),
    CONSTRAINT spot_analysis_spot_id_fkey FOREIGN KEY (spot_id) REFERENCES spots(id) ON DELETE CASCADE
);

-- Table: tricks
-- Purpose: Skateboarding tricks database
CREATE TABLE public.tricks (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamptz DEFAULT now(),
    name text NOT NULL,
    description text,
    difficulty text,
    video_url text,
    CONSTRAINT tricks_pkey PRIMARY KEY (id)
);

-- Table: daily_challenges
-- Purpose: Daily skateboarding challenges for users
CREATE TABLE public.daily_challenges (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamptz DEFAULT now(),
    title text NOT NULL,
    description text,
    xp_reward integer DEFAULT 0,
    is_active boolean DEFAULT true,
    icon text,
    CONSTRAINT daily_challenges_pkey PRIMARY KEY (id)
);

-- Table: user_achievements
-- Purpose: Many-to-many relationship between users and achievements
CREATE TABLE public.user_achievements (
    user_id uuid NOT NULL,
    achievement_id uuid NOT NULL,
    earned_at timestamptz DEFAULT now(),
    CONSTRAINT user_achievements_pkey PRIMARY KEY (user_id, achievement_id),
    CONSTRAINT user_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
);

-- Table: followers
-- Purpose: User following relationships
CREATE TABLE public.followers (
    follower_id uuid NOT NULL,
    following_id uuid NOT NULL,
    created_at timestamptz DEFAULT now(),
    CONSTRAINT followers_pkey PRIMARY KEY (follower_id, following_id)
);

-- Table: spatial_ref_sys
-- Purpose: PostGIS spatial reference systems (auto-created by PostGIS extension)
CREATE TABLE IF NOT EXISTS public.spatial_ref_sys (
    srid integer NOT NULL,
    auth_name varchar(256),
    auth_srid integer,
    srtext varchar(2048),
    proj4text varchar(2048),
    CONSTRAINT spatial_ref_sys_pkey PRIMARY KEY (srid)
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable RLS on all relevant tables
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collection_spots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spot_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spot_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spot_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tricks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;

-- Achievements policies
CREATE POLICY "Anyone can view achievements" ON public.achievements
    FOR SELECT USING (true);

-- User profiles policies
CREATE POLICY "user_profile_select_policy" ON public.user_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "user_profile_insert_policy" ON public.user_profiles
    FOR INSERT WITH CHECK (true);

CREATE POLICY "user_profile_update_policy" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- Spots policies
CREATE POLICY "Users can view public spots" ON public.spots
    FOR SELECT USING ((public = true) OR (user_id = auth.uid()));

CREATE POLICY "Users can insert their own spots" ON public.spots
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own spots" ON public.spots
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own spots" ON public.spots
    FOR DELETE USING (user_id = auth.uid());

-- Collections policies
CREATE POLICY "Users can view their own collections" ON public.collections
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own collections" ON public.collections
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own collections" ON public.collections
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own collections" ON public.collections
    FOR DELETE USING (user_id = auth.uid());

-- Collection spots policies
CREATE POLICY "Users can view collection spots for their collections" ON public.collection_spots
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM collections 
        WHERE collections.id = collection_spots.collection_id 
        AND collections.user_id = auth.uid()
    ));

CREATE POLICY "Users can manage collection spots for their collections" ON public.collection_spots
    FOR ALL USING (EXISTS (
        SELECT 1 FROM collections 
        WHERE collections.id = collection_spots.collection_id 
        AND collections.user_id = auth.uid()
    ));

-- Spot images policies
CREATE POLICY "Users can view images for public spots" ON public.spot_images
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM spots 
        WHERE spots.id = spot_images.spot_id 
        AND (spots.public = true OR spots.user_id = auth.uid())
    ));

CREATE POLICY "Users can insert images for their spots" ON public.spot_images
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own images" ON public.spot_images
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own images" ON public.spot_images
    FOR DELETE USING (user_id = auth.uid());

-- Tricks policies
CREATE POLICY "Anyone can view tricks" ON public.tricks
    FOR SELECT USING (true);

-- Daily challenges policies
CREATE POLICY "Anyone can view daily challenges" ON public.daily_challenges
    FOR SELECT USING (true);

-- User achievements policies
CREATE POLICY "Users can view their own achievements" ON public.user_achievements
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own achievements" ON public.user_achievements
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- ==========================================
-- INDEXES (for performance optimization)
-- ==========================================

-- Spatial indexes for location-based queries
CREATE INDEX IF NOT EXISTS spots_location_idx ON public.spots USING GIST (location);
CREATE INDEX IF NOT EXISTS spots_lat_lng_idx ON public.spots (latitude, longitude);

-- User-based indexes
CREATE INDEX IF NOT EXISTS spots_user_id_idx ON public.spots (user_id);
CREATE INDEX IF NOT EXISTS collections_user_id_idx ON public.collections (user_id);
CREATE INDEX IF NOT EXISTS spot_images_user_id_idx ON public.spot_images (user_id);
CREATE INDEX IF NOT EXISTS spot_reviews_user_id_idx ON public.spot_reviews (user_id);

-- Foreign key indexes
CREATE INDEX IF NOT EXISTS collection_spots_collection_id_idx ON public.collection_spots (collection_id);
CREATE INDEX IF NOT EXISTS collection_spots_spot_id_idx ON public.collection_spots (spot_id);
CREATE INDEX IF NOT EXISTS spot_images_spot_id_idx ON public.spot_images (spot_id);
CREATE INDEX IF NOT EXISTS spot_reviews_spot_id_idx ON public.spot_reviews (spot_id);
CREATE INDEX IF NOT EXISTS spot_analysis_spot_id_idx ON public.spot_analysis (spot_id);

-- Performance indexes
CREATE INDEX IF NOT EXISTS spots_type_idx ON public.spots (type);
CREATE INDEX IF NOT EXISTS spots_difficulty_idx ON public.spots (difficulty);
CREATE INDEX IF NOT EXISTS spots_public_idx ON public.spots (public);
CREATE INDEX IF NOT EXISTS spots_status_idx ON public.spots (status);
CREATE INDEX IF NOT EXISTS daily_challenges_active_idx ON public.daily_challenges (is_active);

-- ==========================================
-- DATABASE STATISTICS
-- ==========================================

/*
Current Database Statistics (as of export):

Table Name         | Live Rows | Inserts | Updates | Deletes
-------------------|-----------|---------|---------|--------
achievements       |         4 |       4 |       0 |       0
collections        |         1 |       1 |       0 |       0
collection_spots   |         1 |       1 |       0 |       0
daily_challenges   |         6 |       6 |       0 |       0
followers          |         1 |       1 |       0 |       0
spots              |        10 |      10 |       0 |       0
spot_images        |         6 |       6 |       0 |       0
spot_reviews       |         0 |       0 |       0 |       0
spot_analysis      |         0 |       0 |       0 |       0
tricks             |         6 |       6 |       0 |       0
user_achievements  |         2 |       2 |       0 |       0
user_profiles      |         4 |       4 |      11 |       0
spatial_ref_sys    |      8500 |    8500 |       0 |       0
*/

-- ==========================================
-- SAMPLE DATA STRUCTURE
-- ==========================================

/*
This database contains the following types of data:

1. User Management:
   - User profiles with personal information
   - User achievements and progress tracking
   - Social features (followers/following)

2. Skateboarding Spots:
   - Detailed spot information with geolocation
   - Multiple images per spot
   - User reviews and ratings
   - AI-powered spot analysis

3. Content & Gamification:
   - Skateboarding tricks database
   - Daily challenges system
   - Achievement system
   - User collections of favorite spots

4. Technical Features:
   - PostGIS integration for spatial queries
   - Row Level Security for data protection
   - JSONB columns for flexible feature storage
   - Comprehensive indexing for performance
*/

-- ==========================================
-- USAGE NOTES
-- ==========================================

/*
To use this schema:

1. Make sure you have a Supabase project or PostgreSQL instance with required extensions
2. Run the extension creation commands first
3. Execute table creation statements
4. Apply RLS policies
5. Create indexes for optimal performance

Key Features:
- Geospatial support for location-based queries
- Flexible JSONB columns for extensible features
- Comprehensive RLS policies for security
- Foreign key relationships for data integrity
- Performance-optimized indexes

For development:
- Auth context requires Supabase auth.uid() function
- Location fields support both geometry and lat/lng formats
- All tables include created_at timestamps
- Most tables include soft-delete capability via status fields
*/

-- ==========================================
-- END OF EXPORT
-- ========================================== 