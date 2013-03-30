module Hallon
	class FIFO
		attr_accessor :format, :output

		@buffer = Array.new
		@playing, @stopped = false

		BUFFER_SIZE = 2048

		def initialize
			@queue = Fifo.new(self.output, :w, :nowait)
			@output ||= "hallon-fifo.pcm"
		end

		# mumbletune intentions:
		# rate = 4800
		# channels = 1
		# type = :int16

		def pause
			@playing = false
		end

		def play
			@playing = true
			@stopped = false
		end

		def stop
			@stopped = true

			@buffer.clear
		end

		def stream # runs indefinitely
			Thread.new do
				loop do
					# Exit if we're stopped
					Thread.current.exit if @stopped

					# Get the next block from Spotify.
					audio_data = yield(BUFFER_SIZE)

					if audio_data.nil? # Audio format has changed, reset buffer.
						@buffer.clear
						break
						
					else # Write to our buffer and, if playing, to the FIFO queue.
						@buffer += audio_data

						if @playing
							@queue.write packed_samples(@buffer)
							@buffer.clear
						end
					end
				end
			end
		end

		private

		def packed_samples(frames)
			frames.each do |sample|
				packed = sample.map { |i| [i].pack("s_") }
				queue.write(packed.join)
			end
		end

	end
end