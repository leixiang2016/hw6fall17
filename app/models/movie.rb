class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
#  def self.find_in_tmdb(string)
#    begin
#      Tmdb::Movie.find(string)
#    rescue Tmdb::InvalidApiKeyError
#        raise Movie::InvalidKeyError, 'Invalid API key'
#    end
#  end

  def self.find_in_tmdb(string)
    results = []
    begin
      if string == "" || string == nil
        return nil
      end
      search_results = Tmdb::Movie.find(string)
      if search_results != nil && !search_results.empty?
        search_results.each do |movie|
          rating = self.get_rating_helper(movie)
          hash_movie = {:tmdb_id => movie.id, :title => movie.title, :rating => rating, :release_date => movie.release_date}
          results.push(hash_movie)
        end
      end
      return results
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.get_rating_helper(movie)
    self.get_rating(movie.id)
  end
  
  def self.get_rating(id)
    releases = Tmdb::Movie.releases(id)["countries"]
    if releases == nil then return "Not rated" end
    rating = releases.select { |iso| iso["iso_3166_1"]=="US" && iso["certification"] != ""}
    
    if (rating == nil || rating[0] == nil) then return "Not rated" end
    return rating[0]["certification"]
  end

  def self.create_from_tmdb (id)
    search_tmdb=Tmdb::Movie.detail(id)
    add_movie={:title => search_tmdb["title"], :rating => self.get_rating(id), :description => search_tmdb["overview"], :release_date => search_tmdb["release_date"]}
    Movie.create!(add_movie)
  end
  
end
