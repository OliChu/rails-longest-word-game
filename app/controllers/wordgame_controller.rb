class WordgameController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @grid = params[:grid].split('')
    @attempt = params[:attempt]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    (0...grid_size).each { grid << ("A".."Z").to_a.sample }
    return grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    # => Init Result
    api_response = []
    # => Test if all "attempt" letters are included in the grid
    if grid_include?(attempt, grid)
      # Contact API
      api_response = contact_api(attempt)
      return build_result(api_response, start_time, end_time)
    else
      result = build_result(api_response, start_time, end_time)
      result[:message] = "Not in the grid"
      result
    end
  end

  def grid_include?(attempt, grid)
    attempt.upcase.split("").each do |letter| # => Test every letter from the "attempt" string
      if grid.include?(letter)
        grid.delete_at(grid.index(letter))
      else
        return false
      end
    end
    return true
  end

  def contact_api(attempt)
    url_api = "https://wagon-dictionary.herokuapp.com/#{attempt.downcase}"
    response_serialized = open(url_api).read
    return JSON.parse(response_serialized)
  end

  def build_result(api_response, start_time, end_time)
    result = {}
    result[:time] = end_time - start_time
    if api_response.size == 3
      api_response["length"].nil? ? result[:score] = 0 : result[:score] = (api_response["length"] - ((end_time - start_time) / 10)).round(2)
      result[:message] = "Well done"
    else
      result[:score] = 0
      result[:message] = "Not an english word"
    end
    result
  end
end
