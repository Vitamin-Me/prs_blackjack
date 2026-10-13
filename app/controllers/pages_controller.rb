class PagesController < ApplicationController
  # root page, for game setup
  def setup
      reset_session

      session[:game_stage] = 0
  end

  # New game has been created, player should only be able to place a bet and see no cards
  def start_game
    return redirect_to pages_home_path if session[:game_stage] != 0 && session[:game_stage] != 3

    # New deck, resets each game AND round
    deck = Deck.new
    deck.shuffle

    # set balances from setup one time on game start, not on a new round
    if session[:game_stage] == 0
      session[:player_balance] = params[:player_balance].to_i
      session[:dealer_balance] = params[:dealer_balance].to_i
    end

    if session[:game_stage] == 0
      session[:win_ratio] = params[:win_ratio].to_i
    end

    session[:game_stage] = 1

    session[:dealer_revealed] = false

    session[:dealer_cards] = card_data(deck.deal(2))
    session[:player_cards] = card_data(deck.deal(2))
    session[:deck_cards]   = card_data(deck.cards)

    session[:game_messages] = [ "Game has started!" ]

    redirect_to pages_home_path
  end

  # main page, hosts the games interaction
  def home
    return redirect_to root_path if session[:player_cards].blank?

    @win_ratio = session[:win_ratio]

    # primary game state to control button interactibility in the view
    # 5 stages, 0-4.
    @game_stage = session[:game_stage] || 1

    @player_bet = session[:player_bet] || 1

    @dealer_balance = session[:dealer_balance]
    @player_balance = session[:player_balance]

    @game_messages = session[:game_messages] || []

    @dealer_revealed = session[:dealer_revealed]

    @dealer_cards = cards_from(session[:dealer_cards])
    @player_cards = cards_from(session[:player_cards])

    # dealer has one hidden card, dont want to sum it hidden
    if @dealer_revealed
      @dealer_score = Hand.new(cards: @dealer_cards).sum
    else
      @dealer_score = Hand.new(cards: [ @dealer_cards.first ]).sum
    end

    @player_score = Hand.new(cards: @player_cards).sum

    @cards_remaining = session[:deck_cards].length
  end

  def start_round
    return redirect_to pages_home_path if session[:game_stage] != 1

    # this is the beginning of stage two, revealing one dealer card and both players, while enabling player actions
    #   and disabling betting and new round

    message = session[:game_messages]

    # check for valid bet before advancing stage
    bet = params[:player_bet].to_i
    balance = session[:player_balance]

    if bet > session[:player_balance]
      message << "Your bet exceeds your balance!"
      return redirect_to pages_home_path
    end

    # hard stop, was previously accessible via the dev console since the previous guard was view only
    if bet <= 0
      message << "Your bet cannot be less than $1"
      return redirect_to pages_home_path
    end

    # valid bet, subtract from balance right away
    session[:player_bet] = bet
    session[:player_balance] -= bet

    # advance the gameplay
    session[:game_stage] = 2

    # check for blackjack
    check_results(blackjack_check: true)

    redirect_to pages_home_path
  end

  def hit
    return redirect_to pages_home_path if session[:game_stage] != 2

    # new deck object, same cards from session
    deck = Deck.new(cards: cards_from(session[:deck_cards]))
    player_cards = cards_from(session[:player_cards])
    dealer_cards = cards_from(session[:dealer_cards])
    player_cards << deck.deal(1).first

    session[:player_cards] = card_data(player_cards)
    session[:deck_cards] = card_data(deck.cards)

    message = session[:game_messages] || []
    message << "You hit!"
    session[:game_messages] = message

    if Hand.new(cards: player_cards).bust?
      check_results(blackjack_check: false)
    end

    redirect_to pages_home_path
  end

  def stand
    return redirect_to pages_home_path if session[:game_stage] != 2

    # new deck object, same cards from session
    deck = Deck.new(cards: cards_from(session[:deck_cards]))
    dealer_cards = cards_from(session[:dealer_cards])
    player_cards = cards_from(session[:player_cards])

    session[:dealer_revealed] = true

    message = session[:game_messages] || []
    message << "You stand!"
    message << "Dealer reveals card"
    session[:game_messages] = message

    # blackjack rules, dealer will hit until 17 or more
    while Hand.new(cards: dealer_cards).sum < 17
      dealer_cards << deck.deal(1).first
    end

    session[:dealer_cards] = card_data(dealer_cards)
    session[:deck_cards] = card_data(deck.cards)

    # Only place to check for blackjack since it has to resolve before an action and 
      # wait until after the hand is set
    check_results(blackjack_check: false)

    redirect_to pages_home_path
  end

  private

  # create the cards
  def card_data(cards)
    cards.map { |card| { "rank" => card.rank, "suit" => card.suit } }
  end

  # grab the current cards in a session
  def cards_from(card_data)
    card_data.map { |data| Card.new(rank: data["rank"], suit: data["suit"]) }
  end

  def check_results(blackjack_check:)
    message = session[:game_messages]

    dealer_cards = cards_from(session[:dealer_cards])
    player_cards = cards_from(session[:player_cards])

    player_bet = session[:player_bet]

    win_ratio = session[:win_ratio]

    result = Game.new(player_hand: Hand.new(cards: player_cards), dealer_hand: Hand.new(cards: dealer_cards),
    player_balance: session[:player_balance], dealer_balance: session[:dealer_balance], blackjack_check: blackjack_check)

    # these two switch cases determine the outcome of the hands and game
    case result.hand
      when :player_bust
          then message << "BUST! Dealer wins this hand!"
          session[:dealer_balance] += player_bet
          session[:game_stage] = 3

      when :dealer_bust
          then message << "Dealer BUST! You win this hand!"
          session[:player_balance] += (player_bet + (player_bet * win_ratio))
          session[:dealer_balance] -= player_bet * win_ratio
          session[:game_stage] = 3

      when :player_wins_round
          then message << "You win this hand!"
          session[:player_balance] += (player_bet + (player_bet * win_ratio))
          session[:dealer_balance] -= player_bet * win_ratio
          session[:game_stage] = 3

      when :dealer_wins_round
          then message << "Dealer wins this hand :("
          session[:dealer_balance] += player_bet
          session[:game_stage] = 3

      when :blackjack
          then message << "You hit BLACKJACK, you win!"
          session[:player_balance] += (player_bet + (player_bet * win_ratio))
          session[:dealer_balance] -= player_bet * win_ratio
          session[:game_stage] = 3

      when :tie
          then message << "Same score, tie!"
          session[:player_balance] += player_bet
          session[:game_stage] = 3
      end

    case result.game(player_balance: session[:player_balance], dealer_balance: session[:dealer_balance])
      when :player_wins
          message << "Dealer has no money left, you win!"
          session[:game_stage] = 4
      when :dealer_wins
          message << "Player has no money left, Dealer wins!"
          session[:game_stage] = 4
      end

    session[:game_messages] = message
  end
end
