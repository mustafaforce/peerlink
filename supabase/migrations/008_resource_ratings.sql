-- Create Resource Ratings Table
CREATE TABLE IF NOT EXISTS resource_ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  resource_id UUID REFERENCES resources(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(resource_id, user_id)
);

-- Create indexes
CREATE INDEX idx_resource_ratings_resource_id ON resource_ratings(resource_id);
CREATE INDEX idx_resource_ratings_user_id ON resource_ratings(user_id);

-- Enable RLS
ALTER TABLE resource_ratings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Anyone can view resource ratings" ON resource_ratings
  FOR SELECT USING (TRUE);

CREATE POLICY "Authenticated users can rate resources" ON resource_ratings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own ratings" ON resource_ratings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own ratings" ON resource_ratings
  FOR DELETE USING (auth.uid() = user_id);

-- Function to update resource rating
CREATE OR REPLACE FUNCTION update_resource_rating(resource_id UUID)
RETURNS VOID AS $$
DECLARE
  new_total INTEGER;
  new_count INTEGER;
BEGIN
  SELECT COALESCE(SUM(rating), 0), COUNT(*) INTO new_total, new_count
  FROM resource_ratings WHERE resource_id = update_resource_rating.resource_id;
  
  UPDATE resources 
  SET total_rating = new_total, ratings_count = new_count 
  WHERE id = update_resource_rating.resource_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
