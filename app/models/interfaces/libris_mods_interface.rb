class LibrisModsInterface
  def initialize(xml)
    @doc = Nokogiri::XML(xml)
  end

  def source
    "libris"
  end

  def id
    @doc.xpath("//mods/identifier[@type='libris']").text
  end

  def author
    @doc.xpath("//mods/name").map do |name| 
      family = name.xpath("namePart[@type='family']").text
      given = name.xpath("namePart[@type='given']").text
      date = name.xpath("namePart[@type='date']").text
      "#{given} #{family} (#{date})"
    end.join("; ")
  end

  def title
    @doc.xpath("//mods/titleInfo[not(@type)]/title").text
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
    @doc.xpath("//mods/titleInfo[@type='alternative']/title").text
  end

  def alt_sub_title
    @doc.xpath("//mods/titleInfo[@type='alternative']/subTitle").text
  end

  def search_string
    [title, sub_title, alt_title, alt_sub_title, author].join(" ").norm
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
