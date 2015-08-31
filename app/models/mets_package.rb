class MetsPackage < ActiveRecord::Base
  validates_presence_of :search_string

  before_validation :generate_data_from_xml
  before_validation :normalise_search_string

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
    hash[:language] = mets_object.language
    hash[:catalog_id] = mets_object.wrapped_object.id
    hash[:source] = mets_object.wrapped_object.source
    self.metadata = hash.to_json
  end

  def metadata_hash
    @metadata_hash ||= JSON.parse(self.metadata)
  end

  def find_file_by_file_id(file_id)
    metadata_hash["file_groups"].each do |file_group| 
      file_group["files"].each do |file| 
        if file["id"] == file_id
          file_name = File.basename(file["location"])
          return {group: file_group["name"], name: file_name, location: file["location"]}
        end
      end
    end
    return nil
  end

  def normalise_search_string
    self.search_string = self.search_string.norm if self.search_string
  end

  def mets_object
    return NullInterface.new if !xml
    @mets_object ||= MetsInterface.new(xml)
  end

  def as_json(opts={})
    return super(except: [:xml, :metadata]).merge({
      package_id: mets_object.id,
      package_create_date: mets_object.create_date,
      package_last_modification_date: mets_object.last_modification_date,
      copyright_status: mets_object.copyright_status,
      creator_agent: mets_object.creator_agent,
      archivist_agent: mets_object.archivist_agent,
      language: mets_object.language,
      catalog_id: mets_object.catalog_id,
      source: mets_object.source,
      page_count: mets_object.page_count,
      publisher: mets_object.publisher,
      file_groups: mets_object.file_groups
    })
  end

  # Sync (import new, delete removed, update existing) from filesystem
  def self.sync
    files = files_in_store
    remove_packages_to_update(files)

    packages_to_delete(files).each do |package_name| 
      MetsPackage.find_by_name(package_name).destroy
    end

    packages_to_add(files).each do |package_name| 
      xmldata = xml_from_package_name(files, package_name)
      MetsPackage.create(xml: xmldata)
    end
  end

  # Return array of files data from all mets xml files in the path structure
  def self.files_in_store
    path = APP_CONFIG["store_path"]
    Dir.glob("#{path}/*/*.xml").map do |filename| 
      xmldata = File.read(filename)
      hashvalue = Digest::SHA256.hexdigest(xmldata)
      mets_object = MetsInterface.new(xmldata)
      { 
        name: mets_object.id,
        filename: filename,
        xml: xmldata,
        xmlhash: hashvalue
      }
    end
  end
  
  # Create filesystem filename from package name
  def self.xml_from_package_name(files, name)
    file_entry = files.find { |file| file[:name] == name }
    if !file_entry
      raise "Should not happen - File missing?"
    end
    file_entry[:xml]
  end

  # Grab only package names from store data
  def self.packages_in_store(files)
    files.map do |filedata|
      filedata[:name]
    end
  end

  # All names of packages in database
  def self.packages_in_db
    MetsPackage.pluck(:name)
  end

  # We will remove all packages from database if they exist in db but their hash differs
  # from the filesystem hash. If they still exist, they will be readded later.
  def self.remove_packages_to_update(files)
    file_hashes = files.map { |x| x[:xmlhash]}
    to_remove = []
    MetsPackage.all.each do |package|
      if !file_hashes.include?(package.xmlhash)
        to_remove << package
      end
    end
    to_remove.each do |package| 
      package.destroy
    end
  end
  
  # We will delete packages if they are in the database but not actually in the filesystem
  def self.packages_to_delete(files)
    packages_in_db - packages_in_store(files)
  end

  # We will add packages if they are in the filesystem, but not yet in the database
  def self.packages_to_add(files)
    packages_in_store(files) - packages_in_db
  end
end
