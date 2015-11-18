#!/usr/bin/ruby
# encoding: UTF-8

require 'optparse'
require 'ostruct'

#
# A class to give this gem some scope. The designed way to use it is through the binary, though all the binary does is call the run method on this class.
#
# ==== Examples
#
#   > xctool -workspace MyApp.workspace -scheme MyApp.scheme -reporter plain analyze | xcanafail
#
# If you want to preserve the exitcode of xctool, set pipefail before running this, e.g.
#
#   > set -o pipefail | xctool -workspace MyApp.workspace -scheme MyApp.scheme -reporter plain analyze | xcanafail
#
class XCAnafail

  # Keep track of which file we are currently looking at
  private
  FILE_LINE_REGEX = /^ *~ Analyze (.*)/

  # Detect when a separator has happened
  private
  SEPARATOR_REGEX = /^-*$/

  # Check to see if there have been any warnings created
  private
  WARNING_COUNT_LINE_REGEX = /^[0-9]* warning.* generated./

  # An enumeration to store some state about where we are in the parse
  private
  module ParseState
    private
    ROOT = 0

    private
    INSIDE_BLOCK = 1 # We are inside a greyed out message block
  end

  #
  # This method will start to read in from either a pipe for stdin, parse the input to detect any analysis warnings and then stream the input back out through stdout
  #
  def self.run

    # Read in the arguments and verify etc.
    options = OpenStruct.new
    options.output = '/dev/null'
    OptionParser.new do |opts|
      opts.banner = 'Usage: xcanafail.rb [options]'

      opts.on('-o', '--out FILE', 'An optional output file') do |o|
        options.output = o
      end

      # No argument, shows at tail.  This will print an options summary.
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end.parse!

    # Assume success, but this might change during the parse
    exit_code = 0

    # open the output file if we have been given one
    File.open(options.output, 'w') do |output|

      current_file = nil

      # We start at the root level
      state = ParseState::ROOT

      # We need to store up the contents of a warning block to deal with it all when we get to the end
      block_contents = nil

      ARGF.each_line { |line|
        # We should appear transparent to the end user
        puts line

        # Get each line from the pipe and see where we are
        if FILE_LINE_REGEX.match(line.encode('UTF-8'))
          current_file = line
          next
        end

        # Or if we are going in/out of a separator block?
        if SEPARATOR_REGEX.match(line)

          if state == ParseState::ROOT
            state = ParseState::INSIDE_BLOCK
            block_contents = []
          else
            # If the last line of the block contains a warning count then we have had a valid warning
            if block_contents.count > 0
              last_line = block_contents.last
              if WARNING_COUNT_LINE_REGEX.match(last_line)
                output.print("Warning -> Error\n")
                output.print(current_file + "\n")
                output.print(block_contents.join("\n"))
                exit_code = 1
              end
            end

            #puts "Leaving warning block : " + block_contents.to_s

            block_contents = nil
            state = ParseState::ROOT
          end

          next
        end

        if state == ParseState::INSIDE_BLOCK
          block_contents << line
        end

        #puts line
      }
    end

    exit(exit_code)

  end

end

