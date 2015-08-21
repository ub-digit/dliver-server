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
    family = @doc.xpath("//mods/name/namePart[@type='family']").text
    given = @doc.xpath("//mods/name/namePart[@type='given']").text
    date = @doc.xpath("//mods/name/namePart[@type='date']").text
    "#{given} #{family} (#{date})"
  end

  def title
    @doc.xpath("//mods/titleInfo[not(@type)]/title").text
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

  def year
    @doc.xpath("//mods/originInfo/dateIssued[not(@*)]").text
  end
end
