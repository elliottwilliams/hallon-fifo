require "mkfifo"

module Hallon
	class Fifo

		def initialize
			@buffer = Array.new
			@playing, @stopped = false
			@buffer_size = 22050

			@output ||= "hallon-fifo.pcm"
			File.delete(@output) if File.exists?(@output)
			File.mkfifo(@output) # Will error if it's overwriting another file
		end

		def format
			@format
		end

		def format=(new_format)
			@format = new_format
			@buffer_size = new_format[:rate] / 2
		end

		def output
			@output
		end

		def output=(new_output)
			old_output, @output = @output, new_output

			File.delete(old_output)
			File.delete(new_output) if File.exists?(new_output)
			File.mkfifo(new_output)
		end

		def drops
			# This SHOULD return the number of times the queue "stuttered"
			0
		end

		def pause
			@playing = false
		end

		def play
			@playing = true
			@stopped = false
		end

		def stop
			@stopped = true
			@stream_thread.exit if @stream_thread

			@buffer.clear
		end

		def stream # runs indefinitely
			@stream_thread = Thread.new do
				queue = File.new(@output, "wb")

				loop do

					# Get the next block from Spotify.
					audio_data = yield(@buffer_size)

					if audio_data.nil? # Audio format has changed, reset buffer.
						@buffer.clear # reset structure
					else # Write to our buffer and, if playing, to the FIFO queue.
						@buffer += audio_data

						queue.syswrite packed_samples(@buffer)
						@buffer.clear
					end

					ensure_playing
				end
			end
		end

		private

		def packed_samples(frames)
			frames.flatten.map { |i| [i].pack("s_") }.join
		end

		def ensure_playing
			play unless @playing
		end

	end
end