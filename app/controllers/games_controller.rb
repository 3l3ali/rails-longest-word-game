require 'time'

class GamesController < ApplicationController
  def game
    @grid = generate_grid(9).join(" ")
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid]
    @start = Time.parse(params[:start])
    @end = Time.now
    @results = run_game(@attempt, @grid, @start, @end)
  end

  private
  WORDS = File.read('/usr/share/dict/words').upcase.split("\n")
  RESULT = { time: 0, translation: "", score: 0, message: "" }

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    value = []
    arr = ('A'..'Z').to_a
    grid_size.times { value << arr.sample }
    return value
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of RESULT
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=fa3f2700-d64e-477f-a89b-6026bfdb3295&input=#{attempt}"

    serialized = open(url).read

    # var is a hash that represents the json
    var = JSON.parse(serialized)

    RESULT[:translation] = var["outputs"][0]["output"]
    RESULT[:message] = "well done"
    RESULT[:score] = attempt.length.to_f / (end_time - start_time).to_f
    RESULT[:time] = (end_time - start_time).to_f

    # checking if the word has translation

    if in?(grid, attempt)
      RESULT[:score] = 0
      RESULT[:translation] = nil
      RESULT[:message] = "not in the grid"
    elsif attempt.length > grid.length
      RESULT[:score] = 0
      RESULT[:translation] = nil
      RESULT[:message] = "not in the grid"
    elsif !WORDS.include?attempt.upcase
      RESULT[:score] = 0
      RESULT[:translation] = nil
      RESULT[:message] = "not an english word"
    elsif insf?(grid, attempt)
      RESULT[:score] = 0
      RESULT[:translation] = nil
      RESULT[:message] = "not in the grid"
    end

    return RESULT
  end

  def in?(grid, attempt)
    flag = false
    attempt.upcase.split('').each do |letter|
      flag = true unless grid.include? letter
      break if flag == true
    end

    return flag
  end

  def insf?(grid, attempt)
    flag = false
    grid = grid.split(' ')
    attempt.upcase.split('').each do |letter|
      if grid.include? letter
        grid.delete_at(grid.index(letter))
      else
        flag = true
      end
      break if flag == true
    end

    return flag
  end
end
