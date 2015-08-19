class MetsPackage < ActiveRecord::Base
  validates_presence_of :search_string

  before_validation :generate_data_from_xml

  # Retrieves data from xml
  def generate_data_from_xml
    if self.xml.present?
      generate_name
      generate_title
      generate_sub_title
      generate_author
      generate_year
      generate_search_string
      generate_copyright
      generate_metadata
    end
  end

  # Sets name based on xml
  def generate_name
    self.name = mets_object.id
  end

  # Sets title from xml
  def generate_title
    self.title = mets_object.title
  end

  # Sets sub_title from xml
  def generate_sub_title
    self.sub_title = mets_object.sub_title
  end

  # Sets author from xml
  def generate_author
    self.author = mets_object.author
  end

  # Sets year from xml
  def generate_year
    self.year = mets_object.year
  end

  # Sets search_string from xml
  def generate_search_string
    self.search_string = mets_object.search_string
  end

  # Sets copyright based on mets info
  def generate_copyright
    self.copyrighted = true
    if mets_object.copyright_status == 'pd'
      self.copyrighted = false
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
    hash[:catalog_id] = mets_object.wrapped_object.id
    hash[:source] = mets_object.wrapped_object.source
    self.metadata = hash.to_json
  end

  def mets_object
    return NullInterface.new if !xml
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
