class Hand
    attr_accessor :cards

    def initialize(cards:)
        @cards = cards
    end

    def sum
        scored = @cards.sum do |card|
            case card.rank
            when 'A'
                11
            when 'K', 'Q', 'J'
                10
            else
                card.rank.to_i
            end
        end

        aces = @cards.count { |card| card.rank == 'A' }

        while scored > 21 && aces > 0
            scored -= 10
            aces -= 1
        end

        scored
    end

    def bust?
        sum > 21
    end

    def blackjack?
        cards.length == 2 && sum == 21
    end

end