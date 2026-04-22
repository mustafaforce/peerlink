-- Create Resources Table
CREATE TABLE IF NOT EXISTS resources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  institution TEXT,
  department TEXT,
  course TEXT,
  subject TEXT,
  ratings_count INTEGER DEFAULT 0,
  total_rating INTEGER DEFAULT 0,
  downloads_count INTEGER DEFAULT 0,
  favorites_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_resources_user_id ON resources(user_id);
CREATE INDEX idx_resources_institution ON resources(institution);
CREATE INDEX idx_resources_department ON resources(department);
CREATE INDEX idx_resources_subject ON resources(subject);
CREATE INDEX idx_resources_created_at ON resources(created_at DESC);

-- Enable RLS
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Anyone can view resources" ON resources
  FOR SELECT USING (TRUE);

CREATE POLICY "Authenticated users can upload resources" ON resources
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own resources" ON resources
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own resources" ON resources
  FOR DELETE USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER update_resources_updated_at
  BEFORE UPDATE ON resources
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to increment downloads count
CREATE OR REPLACE FUNCTION increment_downloads_count(resource_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE resources SET downloads_count = downloads_count + 1 WHERE id = resource_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment favorites count
CREATE OR REPLACE FUNCTION increment_favorites_count(resource_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE resources SET favorites_count = favorites_count + 1 WHERE id = resource_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement favorites count
CREATE OR REPLACE FUNCTION decrement_favorites_count(resource_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE resources SET favorites_count = GREATEST(favorites_count - 1, 0) WHERE id = resource_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
