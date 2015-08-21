# -*- coding: utf-8 -*-
class DcInterface
  def initialize(xml)
    @doc = Nokogiri::XML(xml)
  end

  def source
    return "dc"
  end

  def id
    @doc.xpath("//dc/dc:identifier").text
  end

  def author
    @doc.xpath("//dc/dc:creator").text
  end

  def title
    @doc.xpath("//dc/dc:title").text
  end

  def sub_title
    ""
  end

  def search_string
    [title, sub_title, author].join(" ").norm
  end

  def year
    @doc.xpath("//dc/dc:date").text
  end
end
