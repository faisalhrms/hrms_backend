class AddCompetencyData < ActiveRecord::Migration[7.1]
  def change
    Competency.create :title => "COLLABORATION", :description => "We feel stronger when we are together and our efforts are multiplied through collaboration. Mutual support and common goals lead to a greater success than individual focus. Care and trust are essential for collaboration and without them one person may gain but at the expense of others, resulting in a net loss of contribution.", :rating => 1
    Competency.create :title => "CUSTOMER FOCUS", :description => "We are committed to deliver highest quality product and offer captivating customer experience. We want to build long term relationships with our customers so that they keep on coming back to us and recommend us to others.", :rating => 1
    Competency.create :title => "ACCOUNTABILITY", :description => "We take responsibility of our work and fulfill our commitments to the greatest possible extent. We are committed to deliver the desired results while demonstrating the essential ownership required to achieve the desired outcome.", :rating => 1
    Competency.create :title => "PASSION", :description => "We stand up for what we believe in and show pride in our brand. We are passionate to delight our customers both internal and external with positive energy, optimism & creativity.", :rating => 1
  end
end
