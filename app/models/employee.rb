class Employee < ActiveRecord::Base
  attr_accessible :name, :phone, :mobile , :email,
                   :bbm_pin,  :address   
  validates_presence_of :name
  
end
