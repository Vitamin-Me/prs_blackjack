# README
Welcome to my game of BlackJack where you gamble your heart out until you have removed every dollar from the Dealer! (He's evil its okay)

The goal is simple: set a balance for yourself (the Player) and the Dealer, and use YOUR balance to reduce the DEALERS balance down to ZERO or BELOW. 

The game uses one deck, randomly shuffled each session, and allows the player to place a BET, and HIT or STAND depending on their hand.

Everything runs in the browser session: state, deck, hand, balance, bets, logs, etc. This was not meant to be the long term solution, but protoyping with session variables turned out to be acceptable in the current product. 

Additional features would be adding SPLIT, INSURANCE, and additional actions that resemble the real life game. Also, qualitfy of life features such as animations, color coded logging, nicer cards, and choosing the number of decks. The original scope included user accounts with game history, settings, and a persistant balance, but by the end of development I realized that was not in the cards (get it). 

The game is lightweight, it uses less than 4kb of data to live in the session, and is split into a few core classes and a primary controller. 

There are only two pages, a setup page and the home page which acts as the game table.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
