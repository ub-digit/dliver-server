class MetsPackage < ActiveRecord::Base

  before_create :generate_data_from_xml

  # Retrieves data from xml
  def generate_data_from_xml
    if self.xml.present?
      generate_name
      generate_copyright
      generate_metadata
    end
  end

  # Sets name based on xml
  def generate_name
    self.name = mets_object.id
  end

  # Sets copyright based on mets info
  def generate_copyright
    self.copyrighted = true
    if mets_object.copyright_status == 'pd'
      copyrighted = false
    end
  end

  # Parses xml and stores organized data in db
  def generate_metadata
    hash = {}
    hash[:package_id] = mets_object.id
    hash[:package_create_date] = mets_object.create_date
    hash[:package_last_modification_date] = mets_object.last_modification_date
    hash[:copyright_status] = mets_object.copyright_status
    hash[:creator_agent] = mets_object.creator_agent
    hash[:archivist_agent] = mets_object.archivist_agent
    hash[:file_groups] = mets_object.file_groups
    self.metadata = hash.to_json
  end

  def mets_object
    @mets_object ||= MetsInterface.new(xml)
  end

  def as_json(opts={})
    return super.merge({
      package_id: mets_object.id,
      package_create_date: mets_object.create_date,
      package_last_modification_date: mets_object.last_modification_date,
      copyright_status: mets_object.copyright_status,
      creator_agent: mets_object.creator_agent,
      archivist_agent: mets_object.archivist_agent,
      file_groups: mets_object.file_groups
    })
  end

end
