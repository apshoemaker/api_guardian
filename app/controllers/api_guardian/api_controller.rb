# TODO: User. should be moved to UserStore.
module ApiGuardian
  class ApiController < ActionController::API
    include ::Pundit
    include ApiGuardian::Concerns::ApiErrors::Handler
    include ApiGuardian::Concerns::ApiRequest::Validator

    before_action :doorkeeper_authorize!
    before_action :set_current_user
    before_action :prep_response
    before_action :validate_api_request
    before_action :find_and_authorize_resource, except: [:index, :new, :create]
    after_action :verify_policy_scoped, only: :index
    after_action :verify_authorized, except: [:index]
    append_before_action :set_current_request

    rescue_from Exception, with: :api_error_handler

    attr_reader :current_user

    def index
      @resources = resource_store.paginate(page_params[:number], page_params[:size])
      render json: @resources, include: includes
    end

    def show
      render json: @resource, include: includes
    end

    def create
      authorize resource_class
      @resource = resource_store.create(create_resource_params)
      render json: @resource, status: :created, include: includes
    end

    def update
      @resource = resource_store.update(@resource, update_resource_params)
      render json: @resource, include: includes
    end

    def destroy
      @resource.destroy!
      head :no_content
    end

    protected

    def find_and_authorize_resource
      @resource = resource_store.find(params[:id])
      authorize @resource
    end

    def resource_store
      scope = action_name == 'index' ? policy_scope(resource_class) : nil
      @resource_store ||= find_and_init_store(scope)
    end

    def resource_name
      @resource_name ||= controller_name.classify
    end

    def resource_class
      @resource_class ||= find_resource_class
    end

    # :nocov:
    def includes
      fail 'This needs to be overriden by a child of the API ApplicationController.'
    end
    # :nocov:

    def create_resource_params
      params.require(:data).require(:attributes).permit(create_params)
    end

    def update_resource_params
      params.require(:data).require(:attributes).permit(update_params)
    end

    # :nocov:
    def create_params
      fail 'This needs to be overriden by a child of the API ApplicationController.'
    end
    # :nocov:

    def page_params
      params.fetch(:page, number: 1, size: 25)
    end

    # :nocov:
    def update_params
      fail 'This needs to be overriden by a child of the API ApplicationController.'
    end
    # :nocov:

    private

    def set_current_user
      @current_user = ApiGuardian.configuration.user_class.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def prep_response
      response.headers['Content-Type'] = 'application/vnd.api+json'
    end

    def set_current_request
      ApiGuardian.current_request = request
    end

    def find_and_init_store(scope)
      # Check for app-specfic store
      store = class_exists?(resource_name + 'Store') ?
        resource_name + 'Store' : nil

      # Check for ApiGuardian Store
      unless store
        store = class_exists?('ApiGuardian::Stores::' + resource_name + 'Store') ?
          'ApiGuardian::Stores::' + resource_name + 'Store' : nil
      end

      return store.constantize.new(scope) if store

      fail ApiGuardian::Errors::ResourceStoreMissing, "Could not find a resource store " \
           "for #{resource_name}. Have you created one? You can override `#resource_store` " \
           "in your controller in order to set it up specifically."
    end

    def find_resource_class
      if class_exists?(resource_name)
        return resource_name.constantize
      elsif ApiGuardian.configuration.respond_to? "#{resource_name.downcase}_class"
        return ApiGuardian.configuration.send("#{resource_name.downcase}_class")
      else
        fail ApiGuardian::Errors::ResourceClassMissing, "Could not find a resource class (model) " \
             "for #{resource_name}. Have you created one?"
      end
    end

    def class_exists?(class_name)
      class_name.constantize.is_a?(Class) rescue false
    end
  end
end
