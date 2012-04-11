module UV
  class Async
    include Handle, Resource, Listener

    def initialize(loop, &block)
      raise "no block given" unless block_given?
      @async_block = block
    end

    def send
      check_result UV.async_send(handle)
    end

    private
    def on_async(handle, status)
      @async_block.call(check_result(status))
    end

    def create_handle
      ptr = UV.malloc(UV.handle_size(:uv_async))
      check_result! UV.async_init(loop.pointer, ptr, callback(:on_async))
      ptr
    end
  end
end