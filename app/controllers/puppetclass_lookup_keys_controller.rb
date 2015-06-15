class PuppetclassLookupKeysController < LookupKeysController
  def index
    @lookup_keys = resource_base.search_for(params[:search], :order => params[:order])
                                .paginate(:page => params[:page])
                                .includes(:param_classes)
    @puppetclass_authorizer = Authorizer.new(User.current, :collection => @lookup_keys.map(&:puppetclass_id).compact.uniq)
  end
end
