require "mkfifo"

module Hallon
	class Fifo

		attr_accessor :format, :output

		def initialize
			@buffer = Array.new
			@playing, @stopped = false
			@buffer_size = 22050 # overridden by format=
			@stutter = 0

			@output ||= "hallon-fifo.pcm"
			File.delete(@output) if File.exists?(@output)
			File.mkfifo(@output) # Will error if it's overwriting another file
		end

		def format=(new_format)
			@format = new_format
			@buffer_size = new_format[:rate] / 2
		end

		def output=(new_output)
			old_output, @output = @output, new_output

			File.delete(old_output)
			File.delete(new_output) if File.exists?(new_output)
			File.mkfifo(new_output)
		end

		def drops # Return number of queue stutters since the last call
			current_stutter, @stutter = @stutter, 0
			print "(reported #{current_stutter} stutters) " if current_stutter > 0
			pause if current_stutter > (@format[:rate] * 1)
			current_stutter
		end

		def pause
			@playing = false
			print "\e[1;33m(pause)\e[0m"
		end

		def play
			@playing = true
			@stopped = false
			print "\e[1;32m(play)\e[0m"
		end

		def stop
			@stopped = true
			@stream_thread.exit if @stream_thread

			@buffer.clear
			print "\e[1;31m(stop)\e[0m"
		end

		def reset
			self.output = @output
		end

		def stream # runs indefinitely
			@stream_thread = Thread.new do
				queue = File.new(@output, "wb")
				play # always play initially

				loop do
					if @playing

						start = Time.now.to_f
						completion = start + 0.5

						# Get the next block from Spotify.
						audio_data = yield(@buffer_size)

						if audio_data.nil? # Audio format has changed, reset buffer.
							@buffer.clear
						else
							@buffer += audio_data
							begin
								queue.syswrite packed_samples(@buffer)
							rescue Errno::EPIPE
						        self.reset
							end
							@buffer.clear
						end

						actual = Time.now.to_f
						if actual > completion
							process_stutter(completion, actual)
						else
							sleep completion - actual
						end

					end
				end
			end
		end

		private

		def process_stutter(projected_end, actual_end)
			sec_missed     = actual_end - projected_end
			samples_missed = (sec_missed * @format[:rate]).to_i
			print "(#{samples_missed} stutter) "
			@stutter += samples_missed
		end

		def packed_samples(frames)
			frames.flatten.map { |i| [i].pack("s_") }.join
		end

	end
end