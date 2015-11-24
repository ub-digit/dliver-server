class V1::MetsPackagesController < ApplicationController

  before_filter :validate_access
  before_filter :validate_files_access, only: [:show]

  def index
    #packages = MetsPackage.all
  	query = params[:query]
    facet_queries = params[:facet_queries]
    query_params = {:wt => "json", 
                    :q => "main: (#{query})",
                    :facet => true, 
                    "facet.field" => ["author","type_of_record","copyrighted","language"],
                    "facet.mincount" => 1,
                    :hl => true,
                    "hl.fl" => "main",
                    "hl.simple.pre" => "<em>",
                    "hl.simple.post" => "</em>"}
    
    if facet_queries.present?
      query_params[:fq] = facet_queries
    end

    # Perform SOLR search
    result = SearchEngine.query(query)
    docs = result['response']['docs']
    
    # Create meta object
    meta = {}
    meta[:query] = {}
    meta[:query][:query] = query # Query string
    meta[:query][:total] = result['response']['numFound'] # Total results
    meta[:query][:facet_fields] = [*result['responseHeader']['params']['facet.field']] # Always return an array of given facet fields

    meta[:facet_counts] = {}
    meta[:facet_counts][:facet_fields] = {}
    
    result['facet_counts']['facet_fields'].each do |field, facets|
      meta[:facet_counts][:facet_fields][field.to_sym] = facets.each_slice(2).to_a.map{|x| {label: x[0], count: x[1]}} # Create hash structure from facet count array
    end

    # Loop all docs and inject extra information
    docs.each do |doc|
      id = doc['id']
      doc['highlights'] = {}
      next if result['highlighting'].nil?

      if result['highlighting'][id]
        doc['highlights'] = result['highlighting'][id]
      end
    end

    render json: {mets_packages: docs, meta: meta}, status: 200
  end

  def show
    package = MetsPackage.find_by_name(params[:package_name])

    if package
      @response[:mets_package] = package.as_json
      
      if @unlocked 
        @response[:mets_package][:unlocked] = @unlocked
        @response[:mets_package][:unlocked_until_date] = @unlocked_until_date
      end

      # If user is admin, include links
      if @current_user.has_right?('admin')
        @response[:mets_package][:links] = Link.where(package_name: package.name)
      end

    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find package with name #{params[:package_name]}")
    end

    render_json
  end
end
