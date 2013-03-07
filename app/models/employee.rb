class Employee < ActiveRecord::Base
  attr_accessible :name, :phone, :mobile , :email,
                   :bbm_pin,  :address   
  validates_presence_of :name
  validates_presence_of :phone 
  
  
  validate :phone_play
  
  def phone_play
    errors.add(:name, "This is awesome shite man")
    errors.add(:name, "BOook ckikkin")
  end
  
  def delete
    self.is_deleted = true 
    self.save 
  end
  
  def self.active_objects
    self.where(:is_deleted => false) 
  end
  
end
