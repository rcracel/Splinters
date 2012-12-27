class EventsController < ApplicationController

    def index
        @applications = Application.all.collect { |a| [ a.name, a.id.to_s ] }
        @modules      = Event.collection.distinct( :module_name )
        @environments = Event.collection.distinct( :environment_name )
        @log_levels   = Event.collection.distinct( :log_level )
        @formats      = [ "Kiln Expanded", "Single Line Wide", "Basic" ]

        selected_application = cookies[ :selected_application_id ]
        selected_module      = cookies[ :selected_module_name ]
        selected_environment = cookies[ :selected_environment_name ]
        selected_log_level   = cookies[ :selected_log_level ]
        selected_date_from   = cookies[ :selected_date_from ]

        options = { :order => "timestamp desc", :limit => 20 }

        if ( @applications.find { |a| a[1] == selected_application } )
            
            options[:application_id] = selected_application
        end

        if ( @modules.include? selected_module )
            options[:module_name] = selected_module
        end

        if ( @environments.include? selected_environment )
            options[:environment_name] = selected_environment
        end

        if ( @log_levels.include? selected_log_level )
            options[:log_level] = selected_log_level
        end

        if ( selected_date_from.nil? == false )
            begin
                timezone = current_user.timezone.nil? ? 
                                Time.zone : 
                                ActiveSupport::TimeZone.new( current_user.timezone )

                date = timezone.parse( selected_date_from, "%mm-%dd-%YYYY" )

                options[:timestamp] = { :$gte => date, :$lte => (date + 24.hours) }
            rescue Exception => e
                logger.error "*********** Something wrong happened : #{e.message} for #{selected_date_from}"
            end

        end

        @events       = Event.all options
    end




end
