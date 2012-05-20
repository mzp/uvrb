module UV
  class Async
    include Handle, Resource, Listener

    def initialize(loop, async_ptr, &block)
      assert_block(block)
      assert_arity(1, block)

      @async_block = block

      super(loop, async_ptr)
    end

    def send
      check_result UV.async_send(handle)
    end

    private
    def on_async(handle, status)
      @async_block.call(check_result(status))
    end
  end
end