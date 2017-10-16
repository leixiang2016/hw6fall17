
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect(Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
    context 'ratings defined' do
      it 'should have G PG PG-13 NC-17 R' do
        expected_result = %w(G PG PG-13 NC-17 R)
        result = Movie.all_ratings
        expect(result).to eq(expected_result)
      end
    end
    context 'with matches' do
      it "should render an array of hashes with two movies and if no rating then add Not rated" do
          finds = [double("movie1"), double('movie2')]
          releases = [{"countries" => [{"certification" => "", "iso_3166_1" => "US"}]}, {"countries" => [{"certification" => "PG", "iso_3166_1" => "US"}]}]
          allow(finds[0]).to receive(:id).and_return('1')
          allow(finds[0]).to receive(:title).and_return('first_title')
          allow(finds[0]).to receive(:release_date).and_return('date1')
          allow(finds[1]).to receive(:id).and_return('2')
          allow(finds[1]).to receive(:title).and_return('second_title')
          allow(finds[1]).to receive(:release_date).and_return('date2')
          allow(Tmdb::Movie).to receive(:find).with('shrek').and_return(finds)
          allow(Tmdb::Movie).to receive(:releases).with('1').and_return(releases[0])
          allow(Tmdb::Movie).to receive(:releases).with('2').and_return(releases[1])
          results = Movie.find_in_tmdb('shrek')
          expect(results[0][:tmdb_id]).to eq('1')
          expect(results[1][:tmdb_id]).to eq('2')
          expect(results[0][:title]).to eq('first_title')
          expect(results[1][:title]).to eq('second_title')
          expect(results[0][:rating]).to eq('Not rated')
          expect(results[1][:rating]).to eq('PG')
          expect(results[0][:release_date]).to eq('date1')
          expect(results[1][:release_date]).to eq('date2')
        end
      end
    context 'with no matches' do
      it 'should return empty array []' do
        allow(Tmdb::Movie).to receive(:find).with('').and_return(nil)
        expect(Movie.find_in_tmdb('')).to eq([])
      end
    end
  end
    
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
    
    context 'with valid key' do
      it 'should call create from tmdb' do
        allow(Tmdb::Movie).to receive(:detail).with(118)
        expect {Movie.create_from_tmdb(118)}
      end
    end
    
    context 'with valid movie' do
      it 'should add the movie to the database if no rating then add Not rated' do
        movie_details = {"title" => "title", "release_date" => "date", "overview" => "description"}
        releases = {"countries" => [{"certification" => "", "iso_3166_1" => "US"}]}
        allow(Tmdb::Movie).to receive(:detail).with(0).and_return(movie_details)
        allow(Tmdb::Movie).to receive(:releases).with(0).and_return(releases)
        results = Movie.create_from_tmdb(0)
        expect(results["title"]).to eq(movie_details["title"])
        expect(results["release_date"]).to eq(movie_details["date"])
        expect(results["description"]).to eq(movie_details["overview"])
        expect(results["rating"]).to eq("Not rated")
      end
    end
  end
end
