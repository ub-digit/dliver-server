class SearchEngine
  def initialize
    @solr = RSolr.connect(url: APP_CONFIG['solr_url'])
  end

  def add(data: data)
    @solr.add(data)
  end

  def delete_from_index(package_id: package_id)
    @solr.delete_by_id(package_id)
  end

  def commit
    @solr.update :data => '<commit/>'
    @solr.update :data => '<optimize/>'
  end

  def clear(confirm: false)
    return if !confirm
    @solr.delete_by_query("*:*")
    @solr.commit
  end

  def simple_query(query)
    @solr.get('select', params: {q: query})
  end
end
