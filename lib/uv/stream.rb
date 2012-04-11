module UV
  module Stream
    def listen(backlog, &block)
      raise "no block given" unless block_given?
      @listen_block = block
      check_result! UV.listen(
        handle,
        Integer(backlog),
        callback(:on_listen)
      )
    end

    def accept
      client = loop.send(handle_name.to_sym)
      check_result! UV.accept(handle, client.handle)
      client
    end

    def start_read(&block)
      raise "no block given" unless block_given?
      @read_block = block
      check_result! UV.read_start(
        handle,
        callback(:on_allocate),
        callback(:on_read)
      )
    end

    def stop_read
      check_result! UV.read_stop(handle)
    end

    def write(data, &block)
      @write_block = block
      check_result! UV.write(
        UV.malloc(UV.req_size(:uv_write)),
        handle,
        UV.buf_init(FFI::MemoryPointer.from_string(data), data.respond_to?(:bytesize) ? data.bytesize : data.size),
        1,
        callback(:on_write)
      )
    end

    def shutdown(&block)
      @shutdown_block = block
      check_result! UV.shutdown(
        UV.malloc(UV.req_size(:uv_shutdown)),
        handle,
        callback(:on_shutdown)
      )
    end

    def readable?
      UV.is_readable(handle) != 0
    end

    def writable?
      UV.is_writable(handle) != 0
    end

    private

    def on_listen(server, status)
      @listen_block.call(check_result(status))
    end

    def on_allocate(client, suggested_size)
      UV.buf_init(UV.malloc(suggested_size), suggested_size)
    end

    def on_read(handle, nread, buf)
      e = check_result(nread)
      base = buf[:base]
      unless e
        data = base.read_string(nread)
      end
      UV.free(base)
      @read_block.call(data, e)
    end

    def on_write(req, status)
      UV.free(req)
      @write_block.call(check_result(status)) if @write_block
    end

    def on_shutdown(req, status)
      UV.free(req)
      @shutdown_block.call(check_result(status)) if @shutdown_block
    end
  end
end