# Hallon::FIFO

An audio driver for Hallon, a ruby client for the official Spotify API. Streams audio into a raw PCM-formatted FIFO queue, ideal for input into other applications.

Among other things, FIFO queues can be piped into unix utilities, like SoX, or read as a stream (which is exactly why I wrote this).

## Installation

Add this line to your application's Gemfile:

    gem 'hallon-fifo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hallon-fifo

## Usage

Initialize a Hallon player with the FIFO driver. Pass a `&block` as the second argument to set the FIFO queue's path (or accept the default `hallon-fifo.pcm`):

```ruby
# After loading Hallon and creating a session...

player = Hallon::Player.new Hallon::FIFO, Proc.new do
	@driver.output = "cat-music.pcm"
end
```

Play the FIFO queue elsewhere, for example, with SoX:

```bash
$ play -r 44100 -c 2 -t s16 hallon-fifo.pcm
```