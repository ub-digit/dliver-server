# -*- coding: utf-8 -*-
class DcInterface
  def initialize(xml)
    @doc = Nokogiri::XML(xml)
    @doc.remove_namespaces!
  end

  def set_ordinals_chronologicals(hash)
  end

  def source
    return "dc"
  end

  def id
    @doc.xpath("//simpledc/identifier").text
  end

  def author
    [@doc.xpath("//simpledc/creator").text]
  end

  def authors
    author.join("; ")
  end

  def language
    @doc.xpath("//simpledc/language").text
  end

  def type_of_record
    @doc.xpath("//simpledc/type").map(&:text)
  end

  def publisher
    ""
  end

  def title
    @doc.xpath("//simpledc/title").text
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
    @doc.xpath("//simpledc/date").text
  end
end
