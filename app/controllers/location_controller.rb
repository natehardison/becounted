class LocationController < ApplicationController
  
  def index
    render :action => 'index'
  end
  
  def test
    
  end
  
  def set_zip_code
    @zip_code = ZipCode.find_by_zip_code(params[:zip_code], :include => {:locations => :county})
    
    if @zip_code.nil?
      render :json => {:error => :zip_code_not_in_db} and return if request_is_facebook_ajax?
      flash[:error] = "We can't find that zipcode in our database.  Please try again."
      render :action => 'index'
    elsif !@zip_code.is_in?(@user.voting_state)
      render :json => {:error => :zip_code_out_of_state}  and return if request_is_facebook_ajax?
      flash[:error] = "The zipcode you entered is not in your state.  Please enter 
                        another zipcode, or change your voting state."
      render :action => 'index'
    else
      counties = @zip_code.counties
      if counties.size == 1
        if counties.first.state.votes_by_town? # need to check if only one town
          redirect_to :action => 'select_town', :county => counties.first.id, :zip_code => @zip_code.id
        else # we're done
          county = counties.first
          town = @zip_code.towns.first
          update_user(county, town, @zip_code)
          @info = {:address => county.address, :county => county, :town => town, :zip_code => @zip_code}
          render :action => 'location' and return unless request_is_facebook_ajax?
          render :json => {:complete => true, :fbml_content => render_to_string(:partial => 'location')}
        end
      else
        counties = counties.sort_by { |county| county.name }
        @counties = counties.map do |county| 
          ["#{county.name}, #{county.state.code}", county.id] unless county.address.nil?
        end
        render :action => 'select_county' and return unless request_is_facebook_ajax?
        render :json => {:onconfirm => :set_county, :fbml_content => render_to_string(:partial => 'select_county')}
      end
    end
  end
  
  def set_county
    begin
      county = County.find(params[:county], :include => :state)
    rescue ActiveRecord::RecordNotFound
      render :json => {:error => :invalid_county} and return if request_is_facebook_ajax?
    end
    
    if county.state.votes_by_town? 
      redirect_to :action => 'select_town', :county => params[:county], :zip_code => params[:zip_code]
      return
    end

    begin
      zip_code = ZipCode.find(params[:zip_code], :include => {:locations => :town})
    rescue ActiveRecord::RecordNotFound
      render :json => {:error => :default_error} and return if request_is_facebook_ajax?
    end
    
    town = zip_code.towns.first
    update_user(county, town, zip_code)
    @info = {:address => county.address, :county => county, :town => town, :zip_code => zip_code}
    render :action => 'location' and return unless request_is_facebook_ajax?
    render :json => {:complete => true, :fbml_content => render_to_string(:partial => 'location')}
  end

  def select_town
    begin
      conditions = ['towns.county_id = ? AND locations.zip_code_id = ?', params[:county], params[:zip_code]]
      towns = Town.find(:all, :conditions => conditions, :joins => :locations)
    rescue ActiveRecord::RecordNotFound
      render :json => {:error => :default_error} and return if request_is_facebook_ajax?
    end
    
    if towns.size > 1
      towns = towns.sort_by {|town| town.name }
      @towns = towns.map{ |town| [town.name, town.id] unless town.address.nil? }
      render :action => 'select_town' and return unless request_is_facebook_ajax?
      render :json => {:onconfirm => :set_town, :fbml_content => render_to_string(:partial => 'select_town')}
    else
      town = towns.first
      begin
        county = County.find(params[:county])
        zip_code = ZipCode.find(params[:zip_code])
      rescue ActiveRecord::RecordNotFound
        render :json => {:error => :default_error} and return if request_is_facebook_ajax?
      end
  
      update_user(county, town, zip_code)
      @info = {:address => town.address, :county => county, :town => town, :zip_code => zip_code}
      render :action => 'location' and return unless request_is_facebook_ajax?
      render :json => {:complete => true, :fbml_content => render_to_string(:partial => 'location')}
    end    
  end
  
  def set_town
    begin
      town = Town.find(params[:town])
    rescue ActiveRecord::RecordNotFound
      render :json => {:error => :invalid_town} and return if request_is_facebook_ajax?
    end

    begin
      county = County.find(params[:county])
      zip_code = ZipCode.find(params[:zip_code])
    rescue ActiveRecord::RecordNotFound
      render :json => {:error => :default_error} and return if request_is_facebook_ajax?
    end
    
    update_user(county, town, zip_code)
    @info = {:address => town.address, :county => county, :town => town, :zip_code => zip_code}
    render :action => 'location' and return unless request_is_facebook_ajax?
    render :json => {:complete => true, :fbml_content => render_to_string(:partial => 'location')}
  end
  
  private
  
  def update_user(county, town, zip_code)
    @user.county = county
    @user.town = town
    @user.zip_code = zip_code
    @user.save!
  end
  
end
