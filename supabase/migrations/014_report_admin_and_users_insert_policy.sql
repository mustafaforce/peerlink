-- Align users and reports policies with client repository behavior.

-- Allow users to create/sync their own profile row from the client if needed.
DROP POLICY IF EXISTS "Users can create own profile" ON users;
CREATE POLICY "Users can create own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Dedicated moderation membership table managed by trusted backend/service role.
CREATE TABLE IF NOT EXISTS report_admins (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE report_admins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Report admins can view own membership" ON report_admins;
CREATE POLICY "Report admins can view own membership" ON report_admins
  FOR SELECT USING (auth.uid() = user_id);

-- Enable moderation queries/updates for report admins.
DROP POLICY IF EXISTS "Report admins can view all reports" ON reports;
CREATE POLICY "Report admins can view all reports" ON reports
  FOR SELECT USING (
    EXISTS (
      SELECT 1
      FROM report_admins ra
      WHERE ra.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Report admins can update reports" ON reports;
CREATE POLICY "Report admins can update reports" ON reports
  FOR UPDATE USING (
    EXISTS (
      SELECT 1
      FROM report_admins ra
      WHERE ra.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM report_admins ra
      WHERE ra.user_id = auth.uid()
    )
  );
