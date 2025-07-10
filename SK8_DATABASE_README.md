# SK8 Database Export 🛹

This directory contains a complete export of the SK8 skateboarding platform database, generated using Supabase MCP tools.

## 📁 Files Included

- **`sk8_database_export.sql`** - Complete database schema with all tables, constraints, RLS policies, and documentation
- **`sk8_migration.sql`** - Migration script for setting up the database from scratch
- **`SK8_DATABASE_README.md`** - This documentation file

## 🗃️ Database Overview

The SK8 database is designed for a comprehensive skateboarding platform with the following key features:

### Core Tables
- **`user_profiles`** - Extended user information and preferences
- **`spots`** - Skateboarding locations with geospatial data
- **`spot_images`** - Photo gallery for each spot
- **`spot_reviews`** - User ratings and reviews
- **`spot_analysis`** - AI-powered spot analysis and recommendations

### Social Features
- **`collections`** - User-curated spot collections
- **`followers`** - Social following relationships
- **`achievements`** - Gamification system
- **`user_achievements`** - User progress tracking

### Content & Gamification
- **`tricks`** - Skateboarding tricks database
- **`daily_challenges`** - Daily challenge system

## 🛠️ Database Features

### Extensions Used
- **PostGIS** - Geospatial queries and location-based features
- **uuid-ossp** - UUID generation
- **pgcrypto** - Cryptographic functions
- **pgjwt** - JWT token handling

### Security
- **Row Level Security (RLS)** policies on all tables
- User-based access controls
- Public/private spot visibility

### Performance
- Comprehensive indexing strategy
- Geospatial indexes for location queries
- Foreign key indexes for joins

## 🚀 Setup Instructions

### Option 1: Using Supabase Dashboard
1. Create a new Supabase project
2. Go to SQL Editor in dashboard
3. Paste contents of `sk8_database_export.sql`
4. Execute the script

### Option 2: Using Supabase CLI
```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_ID

# Run the migration
supabase db reset
psql -h YOUR_HOST -U YOUR_USER -d YOUR_DB -f sk8_database_export.sql
```

### Option 3: Using PostgreSQL directly
```bash
# Run the complete export
psql -h localhost -U postgres -d sk8_db -f sk8_database_export.sql

# Or use the migration script
psql -h localhost -U postgres -d sk8_db -f sk8_migration.sql
```

## 📊 Database Statistics

Current database contains:
- **13 core tables** with comprehensive relationships
- **22 RLS policies** for security
- **15+ indexes** for performance optimization
- **Sample data** for development/testing

### Table Data Summary
```
Table               | Live Rows | Purpose
--------------------|-----------|----------------------------------
spots               |        10 | Skateboarding locations
user_profiles       |         4 | User information
spot_images         |         6 | Spot photo galleries
tricks              |         6 | Skateboarding tricks database
daily_challenges    |         6 | Gamification challenges
achievements        |         4 | User achievement system
collections         |         1 | User spot collections
followers           |         1 | Social relationships
user_achievements   |         2 | User progress tracking
collection_spots    |         1 | Collection-spot relationships
spatial_ref_sys     |      8500 | PostGIS spatial references
```

## 🔑 Key Relationships

```
user_profiles
    ↓ (1:many)
spots ← spot_images
    ↓ (1:many)
spot_reviews
spot_analysis

collections
    ↓ (many:many)
collection_spots → spots

users (auth.users)
    ↓ (many:many)
user_achievements → achievements

users
    ↓ (many:many via followers)
users (following relationships)
```

## 🛡️ Security Model

### Row Level Security Policies

**Public Access:**
- Anyone can view achievements, tricks, and daily challenges
- Anyone can view public spots and their images

**User-Specific Access:**
- Users can only manage their own profiles, spots, collections
- Users can only see their own achievements and collections
- Users can only upload images to spots they own

**Geographic Privacy:**
- Spots can be marked as public/private
- Private spots only visible to creators
- Location data uses PostGIS for efficient spatial queries

## 🌍 Geospatial Features

The database includes comprehensive location support:
- **PostGIS geometry columns** for precise spatial queries
- **Latitude/longitude fields** for simple coordinate access
- **Spatial indexes** for fast location-based searches
- **Address fields** for human-readable locations

Example spatial queries:
```sql
-- Find spots within 5km of a location
SELECT * FROM spots 
WHERE ST_DWithin(
    location,
    ST_SetSRID(ST_Point(-122.4194, 37.7749), 4326),
    5000
);

-- Find nearest spots
SELECT *, ST_Distance(location, ST_Point(-122.4194, 37.7749)) as distance
FROM spots 
ORDER BY location <-> ST_Point(-122.4194, 37.7749)
LIMIT 10;
```

## 📱 Integration Notes

### Authentication
- Designed for Supabase Auth integration
- Uses `auth.uid()` function for user context
- Compatible with JWT-based authentication

### API Integration
- All tables have proper foreign key relationships
- JSONB columns for flexible feature storage
- Optimized for REST and GraphQL APIs

### Mobile App Support
- Geolocation-ready for mobile GPS integration
- Image URL storage for mobile photo uploads
- Offline-friendly with proper indexing

## 🔧 Development Setup

After importing the database:

1. **Configure Environment Variables:**
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key
```

2. **Test Database Connection:**
```sql
-- Verify extensions are installed
SELECT extname FROM pg_extension;

-- Check RLS policies
SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public';

-- Test spatial functionality
SELECT ST_AsText(ST_Point(-122.4194, 37.7749));
```

3. **Sample API Calls:**
```javascript
// Get public spots near location
const { data, error } = await supabase
  .from('spots')
  .select('*')
  .eq('public', true)
  .limit(10);

// Get user's collections
const { data, error } = await supabase
  .from('collections')
  .select('*, collection_spots(spots(*))')
  .eq('user_id', user.id);
```

## 🎯 Production Considerations

### Performance
- Enable connection pooling
- Consider read replicas for heavy read workloads
- Monitor spatial query performance

### Backup Strategy
- Regular automated backups
- Point-in-time recovery setup
- Test restore procedures

### Monitoring
- Track RLS policy performance
- Monitor PostGIS query execution times
- Set up alerts for connection limits

## 📝 Changelog

- **v1.0** - Initial database schema with core skateboarding platform features
- Comprehensive RLS security model
- PostGIS integration for geospatial features
- Full social and gamification systems

## 🤝 Contributing

When modifying the database schema:

1. Update both export files
2. Add appropriate RLS policies
3. Include proper indexes
4. Update this documentation
5. Test with sample data

## 📞 Support

For database-related questions:
- Check Supabase documentation for PostGIS features
- Review RLS policy documentation
- Test queries in Supabase SQL Editor

---

**Generated from SK8 Supabase project** | **Database Version:** PostgreSQL 15 with PostGIS 3.3.7 