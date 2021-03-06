# This filter was created by a mutations contributor but was not accepted into
# master. I have copy/pasted it here for our own use.
module Mutations
  class TimeFilter < AdditionalFilter
    @default_options = {
      nils: false, # allows explicit nil to be valid.
      format: nil, # If nil then Time.parse else Time.strptime
      after: nil,  # A time object, representing the minimum time allowed
      before: nil  # A time object, representing the maximum time allowed
    }

    def filter(data)
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      # Now check if it's empty:
      return [data, :empty] if data == ""

      if data.is_a?(Time)
        actual_time = data
      elsif data.is_a?(String)
        begin
          actual_time = if options[:format]
            Time.strptime(data, options[:format])
          else
            Time.parse(data)
          end
        rescue ArgumentError
          return [nil, :time]
        end
      elsif data.respond_to?(:to_time)  # Time
        actual_time = data.to_time
      else
        return [nil, :time]
      end

      # Ok, its a valid time, check if it falls within the range
      if options[:after]
        if actual_time <= options[:after]
          return [nil, :after]
        end
      end

      if options[:before]
        if actual_time >= options[:before]
          return [nil, :before]
        end
      end

      # We win, it's valid!
      [actual_time, nil]
    end
  end
end
