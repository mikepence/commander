
require 'commander/command'
require 'optparse'

module Commander
	
	def init_commander(options = {})
		Commander::Manager.instance options
	end
	
	def add_command(command, &block)
		_command = command
		command = Commander::Command.new(_command)
		yield command if block_given?
		Commander::Manager.instance.add_command command
	end
	alias :command :add_command
	
	def get_command(command)
		Commander::Manager.instance.get_command command
	end
	
	def command_exists?(command)
		Commander::Manager.instance.include? command
	end
	
	def get_info(option)
		Commander::Manager.instance.info[option]
	end
end

module Commander
	class Manager
		
		include Enumerable
		
		attr_reader :user_command, :user_args, :commands, :options, :info
		attr_reader :option_parser, :global_option_parser

		def self.instance(options = {})
			@@instance ||= Commander::Manager.new options
		end
		
		def initialize(options)
			@info, @options = options, {}
			init_info
			at_exit { run_command }
		end
		
		def add_command(command)
			@commands ||= {} and @commands[command.command] = command
		end
		
		def get_command(command)
			@commands[command]
		end
		
		def each
			@commands.each { |command| yield command }	
		end
		
		def include?(command)
			!@commands[command].nil?
		end
		
		def empty?
			@commands.empty?
		end
		
		def length
			@commands.length
		end
		alias :size :length
		
		# -----------------------------------------------------------

			private

		# -----------------------------------------------------------
		
		def run_command
		  debug_abort "please specify arguments." if ARGV.empty?
		  @user_args = ARGV.dup
		  parse_global_options
		  init_command
		end
		
		def init_info
			raise ArgumentError.new('Specify a version for your program in the format of \'0.0.0\'.') unless valid_version @info[:version]
			@info[:major], @info[:minor], @info[:tiny] = parse_version @info[:version]
			@info[:help_generator] ||= Commander::HelpGenerators::Default
		end
		
		def init_command
		  begin
		    user_command = @user_args.shift.to_sym
		    raise "Command #{user_command} does not exist." if @commands[user_command].nil?
	    rescue => e
	      debug_abort "invalid arguments", e
      else
        @user_command = @commands[user_command]
  		  parse_options
  		  exec_command
      end
		end
		
		def parse_options
		  begin
		    @option_parser = OptionParser.new
		    @user_command.options.each { |option| @option_parser.on(*option) } 
		    @option_parser.parse! @user_args
		  rescue => e
		    debug_abort e, e
	    end
		end
		
		def parse_global_options 
		  # TODO: user @parser only not @global_option_parser
		  begin
		    @global_option_parser = OptionParser.new
		    @global_option_parser.on('--help', 'View this help documentation.') { generate_help }
		    @global_option_parser.parse! @user_args
	    rescue => e
	      debug_abort e, e
      end
		end
		
		def exec_command
		  @user_command.invoke :when_called_handler, @user_args
		end
		
		def generate_help
		  # TODO: single-line rescue?
		  begin
		    @info[:help_generator].new self
	    rescue => e
	      debug_abort "Failed to create help generator.", e
      end
		end
		
		def debug_abort(msg, exception = nil)
		  abort msg
		end
		
		def valid_version(version)
			version.split('.').length == 3
		end
		
		def parse_version(version)
		  version.split('.').collect { |v| v.to_i } 
		end
	end
end

module Commander
  module HelpGenerators
    
    # Default help generator.
    #
    # Example formatting:
    #   
    #     Program/command Name
    #
    #     Short program description here.
    #
    #     Options:
    #
    #         -h, --help       Display this help information.
    #
    #     Sub-commands:
    #
    #         com1             Description of com1.
    #         com2             Description of com2.
    #         com3             Description of com3.
    #
    #     Sub-command details:
    #
    #         com1
    #           Manual or short description of com1.
    #
    #           Options:
    #
    #           -c, --core          Set core value.
    #           -r, --recursive     Set core value.
    #         
    #           Examples:
    #            
    #              # Description of example here.
    #              example code
    #
    #              # Description of example 2 here.
    #              example code 2
    #
    class Default
      
      attr_reader :manager
      
      def initialize(manager)
        render
      end
      
      # -----------------------------------------------------------

        private

      # -----------------------------------------------------------
      
      def render
        output = render_header
        output += render_syntax
        output += render_description
        output += render_options
        output += render_examples
        output += render_footer
        puts output and exit
      end
      
      def render_header
        
      end
      
      def render_syntax
        
      end
      
      def render_options
        
      end
      
      def render_option
        
      end
      
      def render_description
        
      end
      
      def render_examples
        
      end
      
      def render_example
        
      end
      
      def render_footer
        
      end
    end
  end
end
