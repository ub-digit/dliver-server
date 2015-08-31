class MetsInterface

  def initialize(xml)
    @doc = Nokogiri::XML(xml)
  end

  # Returns the ID of mets document
  def id
    return @doc.xpath('//mets:metsHdr/@ID').to_s
  end

  # Returns the CREATEDATE of mets document
  def create_date
    return DateTime.iso8601(@doc.xpath('//mets:metsHdr/@CREATEDATE').to_s)
  end

  # Returns the LASTMODDATE of mets document
  def last_modification_date
    return DateTime.iso8601(@doc.xpath('//mets:metsHdr/@LASTMODDATE').to_s)
  end

  # Returns highest page count for the various file groups
  # This equals the number of pages in the package
  # We therefor need to run file_groups before this to count files
  def page_count
    file_groups
    @highest_page_count
  end

  # Returns an array of all agents in document
  def agents
    return @agents unless @agents.nil?
    agents_array = []
    agents = @doc.xpath('//mets:agent')
    agents.each do |agent|
      type = agent.attr('TYPE')
      role = agent.attr('ROLE')
      id = agent.attr('ID')
      if agent.element_children.first.name == 'name'
        name = agent.element_children.first.text
      else
        name = ''
      end

      agent_object = {
        type: type, 
        role: role,
        id: id,
        name: name
      }

      agents_array << agent_object
    end

    @agents = agents_array
    @agents
  end

  # Returns the agent with role CREATOR or nil
  def creator_agent
    @creator_agent ||= agents.select{|x| x[:role] == 'CREATOR'}.first
  end

  # Returns the agent with role ARCHIVIST or nil
  def archivist_agent
    @archivist_agent ||= agents.select{|x| x[:role] == 'ARCHIVIST'}.first
  end

  # Returns copyright status
  def copyright_status
    @copyright_status ||= @doc.xpath('//mets:amdSec/mets:rightsMD/mets:mdWrap/mets:xmlData/copyright').attr('copyright.status').to_s
  end

  # Returns file groups
  def file_groups
    return @file_groups unless @file_groups.nil?
    @file_groups = []
    @highest_page_count = 0
    
    file_groups_xml = @doc.xpath('//mets:fileSec/mets:fileGrp')
    file_groups_xml.each do |file_group|
      file_group_object = {}
      file_group_object[:name] = file_group.attr('USE').to_s

      files = []
      file_group.xpath('.//mets:file').each do |file|
       file_object = {}
       file_object[:id] = file.attr('ID').to_s
       file_object[:location] = file.xpath('.//mets:FLocat').first.attr('xlink:href').to_s
       files << file_object
      end
      if files.count > @highest_page_count
        @highest_page_count = files.count
      end

      file_group_object[:files] = files
      @file_groups << file_group_object
    end

    @file_groups
  end

  def wrapped_object
    mdwrap = @doc.xpath("//mets:dmdSec[@ID='dmdSec1']/mets:mdWrap")
    return nil if !mdwrap
    if mdwrap.attr('MDTYPE').value == "MODS"
      return LibrisModsInterface.new(mdwrap.xpath('.//mets:xmlData/*').to_xml)
    end
    if mdwrap.attr('MDTYPE').value == "DC"
      return DcInterface.new(mdwrap.xpath('.//mets:xmlData/*').to_xml)
    end
    if mdwrap.attr('MDTYPE').value == "OTHER"
      return GubsInterface.new(mdwrap.xpath('.//mets:xmlData/*').to_xml)
    end
  end

  # Data from specialised interface
  def catalog_id
    wrapped_object.id
  end

  def source
    wrapped_object.source
  end

  def title
    wrapped_object.title
  end

  def sub_title
    wrapped_object.sub_title
  end

  def author
    wrapped_object.author
  end

  def language
    wrapped_object.language
  end

  def type_of_record
    wrapped_object.type_of_record
  end

  def publisher
    wrapped_object.publisher
  end

  def search_string
    (wrapped_object.search_string + " " + id).norm
  end

  def year
    wrapped_object.year
  end
end
