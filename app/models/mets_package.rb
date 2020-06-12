require 'pp'
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
      generate_type_of_record
      generate_search_string
      generate_copyright
      generate_metadata
      generate_xmlhash
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

  # Sets hash of METS-XML
  def generate_xmlhash
    self.xmlhash = Digest::SHA256.hexdigest(self.xml)
  end

  # Sets author from xml
  def generate_author
    self.author = mets_object.authors
  end

  # Sets year from xml
  def generate_year
    self.year = mets_object.year
  end

  # Sets type_of_record from xml
  def generate_type_of_record
    self.type_of_record = mets_object.type_of_record
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
    hash[:image_metadata] = mets_object.image_metadata
    hash[:language] = mets_object.language
    hash[:catalog_id] = mets_object.wrapped_object.id
    hash[:source] = mets_object.wrapped_object.source
    mets_object.wrapped_object.set_ordinals_chronologicals(hash)
    self.metadata = hash.to_json
  end

  # Generates thumbnails and stores them in cache folder
  def generate_thumbnails(page: nil, format: 70)
    return if Rails.env == 'test'
    # Get file group from config
    thumbnail_file_group = APP_CONFIG['thumbnail_file_group']
    if !thumbnail_file_group
      raise StandardError, "Missing config thumbnail_file_group"
    end

    source_file_group = metadata_hash['file_groups'].select {|x| x['name'] == thumbnail_file_group}.first
    if !source_file_group
      raise StandardError, "Generate thumbnails: No such file group: #{thumbnail_file_group}"
    end

    # Create thumbnail structure
    destination_path = "#{APP_CONFIG['cache_path']}/#{self.name}/thumbnails/#{format}/"
    FileUtils.mkdir_p(destination_path)

    # If specific page is given, only create thumbnail for it
    if page
      source_file = Pathname.new(APP_CONFIG['store_path'] + '/' + MetsPackage.package_path(package_id: self.name) + '/' + thumbnail_file_group + '/' + page + '.jpg') # Change jpg to dynamic value depending on group
      destination_file = Pathname.new(destination_path + source_file.basename('.*').to_s + '.jpg')
      if !destination_file.exist?
        FileAdapter.create_thumbnail(source_file: source_file.to_s, destination_file: destination_file.to_s, format: format)
      end
    else
      # Generate thumbnails for all files in group
      source_file_group['files'].each do |file|
        source_file = Pathname.new(APP_CONFIG['store_path'] + '/' + MetsPackage.package_path(package_id: self.name) + '/' + file['location'])
        destination_file = Pathname.new(destination_path + source_file.basename('.*').to_s + '.jpg')
        if !destination_file.exist?
          FileAdapter.create_thumbnail(source_file: source_file.to_s, destination_file: destination_file.to_s, format: format)
        end
      end
    end

  end

  # Returns file number of thumbnail file depending on metadata
  def thumbnail_file
    # Find the first TitlePage if one exists
    if metadata_hash["image_metadata"].nil?
      return nil
    end

    image_obj = metadata_hash["image_metadata"].select {|x| x["logical"] == "TitlePage"}.first

    # If none exists, find the first image that is not a ColorTarget
    if image_obj.nil?
      image_obj = metadata_hash["image_metadata"].select {|x| x["physical"] != "ColorTarget"}.first
    end

    if image_obj
      return image_obj['id']
    else
      return nil
    end
  end

  def metadata_hash
    @metadata_hash ||= JSON.parse(self.metadata)
  end

  def find_file_by_file_id(file_id)
    metadata_hash["file_groups"].each do |file_group| 
      file_group["files"].each do |file| 
        if file["id"] == file_id || file["id"] == "#{file_id}.pdf"
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

  def xml_file
    return MetsPackage.xml_file(package_id: self.name)
  end

  # Archives current xml file in history folder
  def archive_xml_file
    timestamp = Time.now.strftime('%Y_%m_%d_%H_%M')
    FileUtils.mkdir_p(archive_path)
    FileUtils.mv(self.xml_file, "#{archive_path}/#{timestamp}_mets.xml")
  end

  def archive_path
    return "#{APP_CONFIG['store_path']}/#{mets_object.id}/history"
  end

  # Returns the path to source mets xml file for a given package id
  def self.xml_file(package_id:)
    return "#{APP_CONFIG['store_path']}/#{MetsPackage.package_path(package_id: package_id)}/#{package_id}_mets.xml"
  end

  def self.package_path(package_id:)
    return package_id[0..-4] + "/" + package_id
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
      file_groups: mets_object.file_groups,
      image_metadata: mets_object.image_metadata
    })
  end

  # Sync (import new, delete removed, update existing) from filesystem
  def self.sync(package_id: nil)
    search_engine = SearchEngine.new
    files = files_in_store(package_id: package_id)
#    search_engine.clear(confirm: true)


    if package_id
      # Remove package for given id
      MetsPackage.find_by_name(package_id).destroy
    else
      # Delete entries which have been changed on file system
      remove_packages_to_update(files)
      # Delete db entries which are not present in file system
      packages_to_delete(files).each do |package_name| 
        package = MetsPackage.find_by_name(package_name)
        numeric_package_name = package.name[/^GUB(\d+)$/, 1].to_i
        search_engine.delete_from_index(package_id: numeric_package_name)
        package.destroy
      end
    end

    packages_to_add(files).each do |package_name| 
      xmldata = xml_from_package_name(files, package_name)
      begin
        package = MetsPackage.create(xml: xmldata)
        update_index(search_engine, package)
      rescue => e
        STDERR.puts "Error on: #{package_name}: #{e.message}"
        raise e
      end
    end

  ensure
    search_engine.commit
  end

  # Return array of files data from all mets xml files in the path structure
  def self.files_in_store(package_id: nil)
    path = APP_CONFIG["store_path"]
    if package_id
      files = MetsPackage.xml_file(package_id: package_id)
    else
      files = "#{path}/GUB*/*/*.xml"
    end
    Dir.glob(files).map do |filename| 
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
      if !file_hashes.include?(package.xmlhash) || ENV['FORCE_RESYNC'] == "YES"
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

  def self.years_from_year_field(year_field)
    return [] if year_field.blank?
    if year_field[/^\d+$/]
      return [year_field.to_i]
    end

    if year_field[/^(\d+)-(\d+)$/]
      return Range.new($1.to_i, $2.to_i).to_a
    end

    return []
  end

  def self.update_index(search_engine, package)
    years = years_from_year_field(package.year)
    numeric_package_name = package.name[/^GUB(\d+)$/, 1].to_i

    indexed_authors = package.mets_object.author.map do |author_entry| 
      "#{author_entry[0]} #{author_entry[1]}"
    end

    search_engine.add(data: {
      id: numeric_package_name,
      alt_sub_title: package.mets_object.alt_sub_title,
      alt_title: package.mets_object.alt_title,
      author: indexed_authors,
      authors: package.mets_object.authors,
      catalog_id: package.mets_object.catalog_id,
      chronological_1: package.metadata_hash['chronological_1'],
      chronological_2: package.metadata_hash['chronological_2'],
      chronological_3: package.metadata_hash['chronological_3'],
      copyrighted: package.copyrighted,
      language: package.mets_object.language,
      name: package.name,
      ordinal_1: package.metadata_hash['ordinal_1'],
      ordinal_2: package.metadata_hash['ordinal_2'],
      ordinal_3: package.metadata_hash['ordinal_3'],
      page_count: package.mets_object.page_count,
      publisher: package.mets_object.publisher,
      pubyear: package.year,
      source: package.mets_object.source,
      sub_title: package.sub_title,
      title: package.title,
      type_of_record: package.type_of_record,
      year: years,
    })
  end
end
