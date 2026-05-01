-- Allow authenticated users to view any user profile (needed for joins on feed, resources, comments)
-- This replaces the restrictive "view own profile only" policy while keeping privacy controls at the app level

-- Drop the old policy that only allows viewing own profile
DROP POLICY IF EXISTS "Users can view own profile" ON users;

-- New policy: any authenticated user can view all profiles
-- The is_private flag is handled at the app level (UI decisions)
CREATE POLICY "Authenticated users can view profiles" ON users
  FOR SELECT USING (auth.role() = 'authenticated');

-- Keep the public profiles policy for unauthenticated users
-- (already exists: "Anyone can view public profiles" with is_private = FALSE)
