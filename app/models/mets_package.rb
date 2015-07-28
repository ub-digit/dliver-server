class MetsPackage < ActiveRecord::Base

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
