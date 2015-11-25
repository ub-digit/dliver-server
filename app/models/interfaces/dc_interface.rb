# -*- coding: utf-8 -*-
class DcInterface
  def initialize(xml)
    @doc = Nokogiri::XML(xml)
  end

  def set_ordinals_chronologicals(hash)
  end

  def source
    return "dc"
  end

  def id
    @doc.xpath("//dc/dc:identifier").text
  end

  def author
    [@doc.xpath("//dc/dc:creator").text]
  end

  def authors
    author.join("; ")
  end

  def language
    @doc.xpath("//dc/dc:language").text
  end

  def type_of_record
    @doc.xpath("//dc/dc:type").map(&:text)
  end

  def publisher
    ""
  end

  def title
    @doc.xpath("//dc/dc:title").text
  end

  def sub_title
    ""
  end

  def alt_title
    []
  end

  def alt_sub_title
    []
  end

  def search_string
    [title, sub_title, author].join(" ").norm
  end

  def year
    @doc.xpath("//dc/dc:date").text
  end
end
