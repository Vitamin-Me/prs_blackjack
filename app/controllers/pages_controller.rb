class PagesController < ApplicationController
  def home
    deck = Deck.new
    deck.shuffle

    @dealer_cards = deck.deal(2)
    @dealer_score = Hand.new(cards: @dealer_cards).sum

    @player_cards = deck.deal(2)
    @player_score = Hand.new(cards: @player_cards).sum

    @cards_remaining = deck.cards.length

  end

  def hit
    @players_hand = Game.new
    @players_hand.add_card(1)
  end
end
