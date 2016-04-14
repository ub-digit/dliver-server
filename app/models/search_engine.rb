class SearchEngine
  def self.solr
    @@solr ||= RSolr.connect(url: APP_CONFIG['solr_url'])
  end

  def solr
    SearchEngine.solr
  end

  def add(data: data)
    solr.add(data)
  end

  def delete_from_index(package_id: package_id)
    solr.delete_by_id(package_id)
  end

  def commit
    solr.update :data => '<commit/>'
    solr.update :data => '<optimize/>'
  end

  def clear(confirm: false)
    return if !confirm
    solr.delete_by_query("*:*")
    solr.commit
  end

  def self.query(query, facets: [])
    highlight_maxcount = 10
    facet_fields = [
      'title_facet',
      'author_facet',
      'type_of_record',
      'language',
      'ordinal_1_facet',
      'ordinal_2_facet',
      'ordinal_3_facet'
    ]
    query_fields = [
      'title^100',
      'author^10',
      'alt_title',
      'sub_title',
      'alt_sub_title',
      'ordinal_1',
      'ordinal_2',
      'ordinal_3',
      'chronological_1',
      'chronological_2',
      'chronological_3',
      'year'
    ]
    
    facet_queries = []
    facets.each do |facet|
      next if facet['facet'] == "copyrighted"
      facet_queries << "#{facet['facet']}:\"#{facet['value']}\""
    end
    facet_queries << "copyrighted:\"false\""

    solr.get('select', params: {
      "defType" => "edismax",
      q: query,
      qf: query_fields.join(" "),
      hl: true,
      "hl.fl" => "*",
      "hl.snippets" => highlight_maxcount,
      facet: true,
      "facet.field" => facet_fields,
      "facet.mincount" => 1,
      fl: "score,*",
      fq: facet_queries,
      "hl.simple.pre" => "<span class='highlighted-text'>",
      "hl.simple.post" => "</span>",
      rows: 20,
      "q.alt" => '*',
      sort: "score desc, name desc"
    }.compact)
  end
end
