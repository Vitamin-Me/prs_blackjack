class PagesController < ApplicationController
  def home
    return redirect_to root_path if session[:player_cards].blank?

    @dealer_cards = cards_from(session[:dealer_cards])
    @player_cards = cards_from(session[:player_cards])

    @dealer_score = Hand.new(cards: @dealer_cards).sum
    @player_score = Hand.new(cards: @player_cards).sum

    @cards_remaining = session[:deck_cards].length

  end

  def start_game
    deck = Deck.new
    deck.shuffle

    session[:dealer_cards] = card_data(deck.deal(2))
    session[:player_cards] = card_data(deck.deal(2))
    session[:deck_cards]   = card_data(deck.cards)

    redirect_to pages_home_path
  end

  def hit
    deck = Deck.new(cards: cards_from(session[:deck_cards]))
    player_cards = cards_from(session[:player_cards])
    player_cards << deck.deal(1).first  

    session[:player_cards] = card_data(player_cards)
    session[:deck_cards] = card_data(deck.cards)

    redirect_to pages_home_path
  end


  private

  def card_data(cards)
    cards.map { |card| { "rank" => card.rank, "suit" => card.suit } }
  end

  def cards_from(card_data)
    card_data.map { |data| Card.new(rank: data["rank"], suit: data["suit"]) }
  end
end
