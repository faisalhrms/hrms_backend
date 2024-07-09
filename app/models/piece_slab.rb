class PieceSlab < ApplicationRecord

  ########## Validation ############
  validates :name, 				:uniqueness => { scope: :company_id }

  ####### Relation Ship #########
  belongs_to 	:company
  belongs_to 	:location
  has_many    :piece_slab_details,   :dependent => :destroy
end
