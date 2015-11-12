#!/usr/bin/ruby


current_file = nil

# Keep track of which file we are currently looking at
FILE_LINE_REGEX = /^ *~ Analyze (.*)/

# Detect when a separator has happened
SEPARATOR_REGEX = /^-*$/

# Check to see if there have been any warnings created 
WARINING_COUNT_LINE_REGEX = /^[0-9]* warning.* generated./

# An enumeration to store some state about where we are in the parse
module ParseState
  ROOT = 0
  INSIDE_BLOCK = 1 # We are inside a greyed out message block
end

# We start at the root level
state = ParseState::ROOT

# We need to store up the contents of a warning block to deal with it all when we get to the end
block_contents = nil

# Assume success, but this might change during the parse
exit_code = 0

ARGF.each_line { |line|

  # Get each line from the pipe and see where we are
  if FILE_LINE_REGEX.match(line)
    current_file = line
    #puts line
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
        if WARINING_COUNT_LINE_REGEX.match(last_line)
          puts "Warning -> Error"
          puts current_file
          puts block_contents
          error_code = 1
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

exit(exit_code)
