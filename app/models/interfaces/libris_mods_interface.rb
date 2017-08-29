class LibrisModsInterface
  def initialize(xml)
    @doc = Nokogiri::XML(xml)
#    @ns = {mods: "http://www.loc.gov/mods/v3"}
    @doc.remove_namespaces!
  end

  def set_ordinals_chronologicals(hash)
    hash[:ordinal_1] = ordinal(1) if ordinal(1)
    hash[:ordinal_2] = ordinal(2) if ordinal(2)
    hash[:ordinal_3] = ordinal(3) if ordinal(3)
    hash[:chronological_1] = chronological(1) if chronological(1)
    hash[:chronological_2] = chronological(2) if chronological(2)
    hash[:chronological_3] = chronological(3) if chronological(3)
  end

  def ordinal(num)
    caption = @doc.xpath("//mods/part/detail[@type='ordinal_#{num}']/caption").text
    number = @doc.xpath("//mods/part/detail[@type='ordinal_#{num}']/number").text
    value = "#{caption} #{number}"
    return nil if value.blank?
    value
  end

  def chronological(num)
    caption = @doc.xpath("//mods/part/detail[@type='chronological_#{num}']/caption").text
    number = @doc.xpath("//mods/part/detail[@type='chronological_#{num}']/number").text
    value = "#{caption} #{number}"
    return nil if value.blank?
    value
  end

  def source
    "libris"
  end

  def id
    @doc.xpath("//mods/identifier[@type='libris']").text
  end

  def author
    @doc.xpath("//mods/name[./role/roleTerm != 'rpy' and ./role/roleTerm != 'pbd']").map do |name|
      family = name.xpath("namePart[@type='family']").text
      given = name.xpath("namePart[@type='given']").text
      date = name.xpath("namePart[@type='date']").text
      [given, family, date]
    end
  end

  def authors
    author.map do |author_entry|
      given, family, date = author_entry
      tmp = "#{given} #{family}"
      tmp += " (#{date})" if date
      tmp
    end.join("; ")
  end

  def title
    myTitle=@doc.xpath("//mods/titleInfo[not(@type)]/title").text
    myNonSort=@doc.xpath("//mods/titleInfo[not(@type)]/nonSort").text
    subTitle=@doc.xpath("//mods/titleInfo[not(@type)]/subTitle").text
    partNumber=@doc.xpath("//mods/titleInfo[not(@type)]/partNumber").text
    partName=@doc.xpath("//mods/titleInfo[not(@type)]/partName").text

    myNonSort = nil if myNonSort.blank?
    subTitle = nil if subTitle.blank?
    partNumber = nil if partNumber.blank?
    partName = nil if partName.blank?

    [myNonSort, myTitle, subTitle, partNumber, partName].compact.join(' ')
  end

  def language
    @doc.xpath("//mods/language[not(@*)]/languageTerm").first.text
  end

  def type_of_record
    types = []
    @doc.xpath("//mods/genre").each do |genre|
      types << genre.text
    end
    types << @doc.xpath("//mods/typeOfResource").text
    types
  end

  def sub_title
    @doc.xpath("//mods/titleInfo[not(@type)]/subTitle").text
  end

  def alt_title
    @doc.xpath("//mods/titleInfo[@type='alternative']/title").map { |x| x.text }
  end

  def alt_sub_title
    @doc.xpath("//mods/titleInfo[@type='alternative']/subTitle").map { |x| x.text }
  end

  def search_string
    [title, sub_title, alt_title.join(" "), alt_sub_title.join(" "), authors].join(" ").norm
  end

  # There is not enough information in the MODS to select a proper publisher.
  # We pick the first one only.
  def publisher
    publisher = @doc.xpath("//mods/originInfo/publisher").first
    return publisher.text if publisher.present?
    ""
  end

  def year
    if @doc.xpath("//mods/originInfo/dateIssued[@encoding='marc']")
      year_start = @doc.xpath("//mods/originInfo/dateIssued[@encoding='marc'][@point='start']")
      year_end = @doc.xpath("//mods/originInfo/dateIssued[@encoding='marc'][@point='end']")
      if year_start.present? && year_end.present?
        return "#{year_start.text}-#{year_end.text}"
      end
      return @doc.xpath("//mods/originInfo/dateIssued[@encoding='marc']").text
    end
    year = @doc.xpath("//mods/originInfo/dateIssued[not(@*)]").first
    return year.text if year.present?
    ""
  end
end
