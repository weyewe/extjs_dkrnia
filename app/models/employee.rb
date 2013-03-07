class Employee < ActiveRecord::Base
  include UniqueNonDeleted
  attr_accessible :name, :phone, :mobile , 
                  :email, :bbm_pin, :address 
  
  validates_presence_of :name 
  validate :unique_non_deleted_name 
 
  
  def self.active_objects
    self.where(:is_deleted => false ).order("id DESC")
  end
  
  def delete( employee) 
    return nil if employee.nil?
    
    self.is_deleted = true 
    self.save 
  end
end
