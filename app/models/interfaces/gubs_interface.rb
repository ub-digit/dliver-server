# -*- coding: utf-8 -*-
class GubsInterface
  def initialize(xml)
    @doc = Nokogiri::XML(xml)
  end

  def source
    source_ref = @doc.xpath("//gubs/manuscript/@hd-ref").text
    return "document" if source_ref == "dokument"
    return "letter" if source_ref == "brev"
    return "unknown"
  end

  def id
    @doc.xpath("//gubs/manuscript").attr('hd-id').text
  end

  def author
    if source == "document"
      family = @doc.xpath("//gubs/manuscript/document/originator/name-family").text
      given = @doc.xpath("//gubs/manuscript/document/originator/name-given").text
      date = @doc.xpath("//gubs/manuscript/document/originator/name-date").text
      return "#{given} #{family} (#{date})"
    end
    if source == "letter"
      sender_data = sender
      return "#{sender_data[0]} #{sender_data[1]} (#{sender_data[2]})"
    end
  end

  def title
    if source == "document"
      return @doc.xpath("//gubs/manuscript/#{source}/unittitle").text
    end
    if source == "letter"
      unitdate = @doc.xpath("//gubs/manuscript/#{source}/unitdate").text
      constructed_title = "Brev från #{sender[0]} #{sender[1]} till #{recipient[0]} #{recipient[1]}"
      if unitdate != "-"
        contructed_title += " (#{unitdate})"
      end
      return constructed_title
    end
  end

  def sub_title
    ""
  end

  def sender
    family = @doc.xpath("//gubs/manuscript/letter/sender/name-family").text
    given = @doc.xpath("//gubs/manuscript/letter/sender/name-given").text
    date = @doc.xpath("//gubs/manuscript/letter/sender/name-date").text
    [given, family, date]
  end

  def recipient
    family = @doc.xpath("//gubs/manuscript/letter/recipient/name-family").text
    given = @doc.xpath("//gubs/manuscript/letter/recipient/name-given").text
    date = @doc.xpath("//gubs/manuscript/letter/recipient/name-date").text
    [given, family, date]
  end

  def search_string
    [title, sub_title, author].join(" ")
  end

  def year
    if source == "document"
      year_string = @doc.xpath("//gubs/manuscript/document/searchdate").text
      year = year_string.scan(/^(\d+)/).first
      year = !year ? "-" : year.first
    end
    if source == "letter"
      year_string = @doc.xpath("//gubs/manuscript/letter/searchdate").text
      year = year_string.scan(/^(\d+)/).first
      year = !year ? "-" : year.first
    end

    year
  end
end
