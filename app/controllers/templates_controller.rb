class TemplatesController < ApplicationController
  include Foreman::Renderer
  include Foreman::Controller::ProvisioningTemplates
  include Foreman::Controller::AutoCompleteSearch

  before_filter :handle_template_upload, :only => [:create, :update]
  before_filter :find_resource, :only => [:edit, :update, :destroy, :clone_template, :lock, :unlock]
  before_filter :load_history, :only => :edit
  before_filter :type_name_plural, :type_name_singular, :resource_class

  include TemplatePathsHelper

  def index
    @templates = resource_base.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
    @templates = @templates.includes(resource_base.template_includes)
  end

  def new
    @template = resource_class.new
  end

  # we can't use `clone` here, ActionController disables public method that are inherited and present in Base
  # parent classes (so all controllers don't have actions like id, clone, dup, ...), unfortunatelly they don't
  # detect method definitions in controller ancestors, only methods defined directly in child controller
  def clone_template
    @template = @template.dup
    @template.locked = false
    load_vars_from_template
    flash[:warning] = _("The marked fields will need reviewing")
    @template.valid?
    render :action => :new
  end

  def lock
    set_locked true
  end

  def unlock
    set_locked false
  end

  def create
    @template = resource_class.new(foreman_params)
    if @template.save
      process_success :object => @template
    else
      process_error :object => @template
    end
  end

  def edit
    load_vars_from_template
  end

  def update
    if @template.update_attributes(foreman_params)
      process_success :object => @template
    else
      load_history
      process_error :object => @template
    end
  end

  def revision
    audit = Audit.find(params[:version])
    render :json => audit.revision.template
  end

  def destroy
    if @template.destroy
      process_success :object => @template
    else
      process_error :object => @template
    end
  end

  def auto_complete_controller_name
    type_name_plural
  end

  private

  def set_locked(locked)
    @template.locked = locked
    if @template.save
      process_success :success_msg => (locked ? _('Template locked') : _('Template unlocked')), :success_redirect => :back, :object => @template
    else
      process_error :object => @template
    end
  end

  def load_history
    return unless @template
    @history = Audit.descending.where(:auditable_id => @template.id, :auditable_type => @template.class, :action => 'update')
  end

  def action_permission
    case params[:action]
      when 'lock', 'unlock'
        :lock
      when 'clone_template'
        :view
      else
        super
    end
  end

  def resource_name
    'template'
  end

  def resource_class
    @resource_class ||= controller_name.singularize.classify.constantize
  end

  def type_name_plural
    @type_name_plural ||= type_name_singular.pluralize
  end
end
