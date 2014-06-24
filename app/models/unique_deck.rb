class UniqueDeck < ActiveRecord::Base
  attr_accessible :cardstring, :name, :user_id, :num_matches, :winrate, :num_users, :klass_id

  is_impressionable

  acts_as_taggable

  ### ASSOCIATIONS:

  has_many :decks
  has_many :deck_versions
  
  has_many :unique_deck_cards
  has_many :cards, through: :unique_deck_cards
  
  has_many :matches, through: :match_unique_decks
  has_many :match_unique_decks

  ### CALLBACKS:

  after_create :create_cards_from_cardstring, if: :cardstring
  
  ### VALIDATIONS:

  validates :cardstring, presence: true

  ### CLASS METHODS
  
  def self.update_stats(id)
    if unique_deck = UniqueDeck.find_by_id(id)
      unique_deck.update_stats!
    end
  end
  
  def self.create_from_deck(deck)
    unique_deck = create(cardstring: deck.cardstring, klass_id:   deck.klass_id )
    
    unique_deck
  end
  
  ### INSTANCE METHODS:

  def update_stats!
    update_stats
    save
  end
  
  def update_stats
    self.num_minions = cards.where(type_id: 1).count
    self.num_spells  = cards.where(type_id: 2).count
    self.num_weapons = cards.where(type_id: 3).count
    self.num_users   = decks.where(klass_id: klass_id).count
    self.num_matches = decks.sum(:user_num_matches)
    self.num_wins    = decks.sum(:user_num_wins)
    self.num_losses  = decks.sum(:user_num_losses)
    self.winrate     = (num_matches.present? && num_matches != 0) ? (num_wins.to_f / num_matches.to_f * 100) : 0
  end
  
  private
  
  def create_cards_from_cardstring
    cardstring.split(',').each do |card_data|
      id, count = card_data.split('_').map(&:to_i)
      count.times do
        unique_deck_cards.create(card_id: id)
      end
    end
  end
end
