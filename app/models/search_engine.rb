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
    facet_fields = ['author_facet', 'type_of_record', 'copyrighted', 'language']

    solr.get('select', params: {
      "defType" => "edismax",
      q: query,
      qf: "title^100 author^10 alt_title sub_title alt_sub_title",
      hl: true,
      "hl.fl" => "*",
      "hl.snippets" => highlight_maxcount,
      facet: true,
      "facet.field" => facet_fields,
      "facet.mincount" => 1,
      fl: "score,*"
    })
  end
end
