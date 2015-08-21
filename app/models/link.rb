class Link < ActiveRecord::Base
  validates_presence_of :link_hash
  validates_presence_of :package_name
  validates_presence_of :expire_date
  validate :expire_date_validity

  def self.generate(package_name, expire_date)
    Link.new(package_name: package_name, expire_date: expire_date, link_hash: SecureRandom.uuid)
  end

  def is_valid?
    return true if expire_date > Time.now
    false
  end

  def expire_date_validity
    if !expire_date || expire_date < Time.now.to_date
      @errors.add(:expire_date, "Expire date cannot be in the past")
    end
  end
end
