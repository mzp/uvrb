require 'ffi'

module UV
  extend FFI::Library
  FFI::DEBUG = 10

  ffi_lib(FFI::Library::LIBC)
  # memory management
  attach_function :malloc, [:size_t], :pointer
  attach_function :free, [:pointer], :void

  ffi_lib("Ws2_32.dll") if FFI::Platform.windows?
  attach_function :ntohs, [:ushort], :ushort

  begin
    # bias the library discovery to a path inside the gem first, then
    # to the usual system paths
    path_to_internal_libuv = File.dirname(__FILE__) + '/../ext'
    LIBUV_PATHS = [
      path_to_internal_libuv, '/usr/local/lib', '/opt/local/lib', '/usr/lib64'
    ].map{|path| "#{path}/libuv.#{FFI::Platform::LIBSUFFIX}"}
    libuv = ffi_lib(LIBUV_PATHS + %w{libuv}).first
  rescue LoadError
    warn <<-WARNING
      Unable to load this gem. The libuv library (or DLL) could not be found.
      If this is a Windows platform, make sure libuv.dll is on the PATH.
      For non-Windows platforms, make sure libuv is located in this search path:
      #{LIBUV_PATHS.inspect}
    WARNING
    exit 255
  end

  require 'uv/types'

  attach_function :loop_new, :uv_loop_new, [], :uv_loop_t
  attach_function :loop_delete, :uv_loop_delete, [:uv_loop_t], :void
  attach_function :default_loop, :uv_default_loop, [], :uv_loop_t
  @blocking = true
  attach_function :run, :uv_run, [:uv_loop_t], :int
  attach_function :run_once, :uv_run_once, [:uv_loop_t], :int
  attach_function :update_time, :uv_update_time, [:uv_loop_t], :void
  attach_function :now, :uv_now, [:uv_loop_t], :int64

  attach_function :last_error, :uv_last_error, [:uv_loop_t], :uv_err_t
  attach_function :strerror, :uv_strerror, [:uv_err_t], :string
  attach_function :err_name, :uv_err_name, [:uv_err_t], :string

  attach_function :ref, :uv_ref, [:uv_handle_t], :void
  attach_function :unref, :uv_unref, [:uv_handle_t], :void
  attach_function :is_active, :uv_is_active, [:uv_handle_t], :int
  attach_function :close, :uv_close, [:uv_handle_t, :uv_close_cb], :void
  attach_function :is_closing, :uv_is_closing, [:uv_handle_t], :int

  attach_function :buf_init, :uv_buf_init, [:pointer, :size_t], :uv_buf_t
  attach_function :strlcpy, :uv_strlcpy, [:string, :string, :size_t], :size_t
  attach_function :strlcat, :uv_strlcat, [:string, :string, :size_t], :size_t

  attach_function :listen, :uv_listen, [:uv_stream_t, :int, :uv_connection_cb], :int
  attach_function :accept, :uv_accept, [:uv_stream_t, :uv_stream_t], :int
  attach_function :read_start, :uv_read_start, [:uv_stream_t, :uv_alloc_cb, :uv_read_cb], :int
  attach_function :read_stop, :uv_read_stop, [:uv_stream_t], :int
  attach_function :read2_start, :uv_read2_start, [:uv_stream_t, :uv_alloc_cb, :uv_read2_cb], :int
  attach_function :write, :uv_write, [:uv_write_t, :uv_stream_t, :pointer, :int, :uv_write_cb], :int
  attach_function :write2, :uv_write2, [:uv_write_t, :uv_stream_t, :pointer, :int, :uv_stream_t, :uv_write_cb], :int
  attach_function :is_readable, :uv_is_readable, [:uv_stream_t], :int
  attach_function :is_writable, :uv_is_writable, [:uv_stream_t], :int
  attach_function :shutdown, :uv_shutdown, [:uv_shutdown_t, :uv_stream_t, :uv_shutdown_cb], :int

  attach_function :tcp_init, :uv_tcp_init, [:uv_loop_t, :uv_tcp_t], :int
  attach_function :tcp_nodelay, :uv_tcp_nodelay, [:uv_tcp_t, :int], :int
  attach_function :tcp_keepalive, :uv_tcp_keepalive, [:uv_tcp_t, :int, :uint], :int
  attach_function :tcp_simultaneous_accepts, :uv_tcp_simultaneous_accepts, [:uv_tcp_t, :int], :int
  attach_function :tcp_bind, :uv_tcp_bind, [:uv_tcp_t, :sockaddr_in], :int
  attach_function :tcp_bind6, :uv_tcp_bind6, [:uv_tcp_t, :sockaddr_in6], :int
  attach_function :tcp_getsockname, :uv_tcp_getsockname, [:uv_tcp_t, :pointer, :pointer], :int
  attach_function :tcp_getpeername, :uv_tcp_getpeername, [:uv_tcp_t, :pointer, :pointer], :int
  attach_function :tcp_connect, :uv_tcp_connect, [:uv_connect_t, :uv_tcp_t, :sockaddr_in, :uv_connect_cb], :int
  attach_function :tcp_connect6, :uv_tcp_connect6, [:uv_connect_t, :uv_tcp_t, :sockaddr_in6, :uv_connect_cb], :int

  attach_function :udp_init, :uv_udp_init, [:uv_loop_t, :uv_udp_t], :int
  attach_function :udp_bind, :uv_udp_bind, [:uv_udp_t, :sockaddr_in, :uint], :int
  attach_function :udp_bind6, :uv_udp_bind6, [:uv_udp_t, :sockaddr_in6, :uint], :int
  attach_function :udp_getsockname, :uv_udp_getsockname, [:uv_udp_t, :pointer, :pointer], :int
  attach_function :udp_set_membership, :uv_udp_set_membership, [:uv_udp_t, :string, :string, :uv_membership], :int
  attach_function :udp_set_multicast_loop, :uv_udp_set_multicast_loop, [:uv_udp_t, :int], :int
  attach_function :udp_set_multicast_ttl, :uv_udp_set_multicast_ttl, [:uv_udp_t, :int], :int
  attach_function :udp_set_broadcast, :uv_udp_set_broadcast, [:uv_udp_t, :int], :int
  attach_function :udp_set_ttl, :uv_udp_set_ttl, [:uv_udp_t, :int], :int
  attach_function :udp_send, :uv_udp_send, [:uv_udp_send_t, :uv_udp_t, :pointer, :int, :sockaddr_in, :uv_udp_send_cb], :int
  attach_function :udp_send6, :uv_udp_send6, [:uv_udp_send_t, :uv_udp_t, :pointer, :int, :sockaddr_in6, :uv_udp_send_cb], :int
  attach_function :udp_recv_start, :uv_udp_recv_start, [:uv_udp_t, :uv_alloc_cb, :uv_udp_recv_cb], :int
  attach_function :udp_recv_stop, :uv_udp_recv_stop, [:uv_udp_t], :int

  attach_function :tty_init, :uv_tty_init, [:uv_loop_t, :uv_tty_t, :uv_file, :int], :int
  attach_function :tty_set_mode, :uv_tty_set_mode, [:uv_tty_t, :int], :int
  attach_function :tty_reset_mode, :uv_tty_reset_mode, [], :void
  attach_function :tty_get_winsize, :uv_tty_get_winsize, [:uv_tty_t, :pointer, :pointer], :int

  attach_function :guess_handle, :uv_guess_handle, [:uv_file], :uv_handle_type

  attach_function :pipe_init, :uv_pipe_init, [:uv_loop_t, :uv_pipe_t, :int], :int
  attach_function :pipe_open, :uv_pipe_open, [:uv_pipe_t, :uv_file], :void
  attach_function :pipe_bind, :uv_pipe_bind, [:uv_pipe_t, :string], :int
  attach_function :pipe_connect, :uv_pipe_connect, [:uv_connect_t, :uv_pipe_t, :string, :uv_connect_cb], :void
  attach_function :pipe_pending_instances, :uv_pipe_pending_instances, [:uv_pipe_t, :int], :void

  attach_function :prepare_init, :uv_prepare_init, [:uv_loop_t, :uv_prepare_t], :int
  attach_function :prepare_start, :uv_prepare_start, [:uv_prepare_t, :uv_prepare_cb], :int
  attach_function :prepare_stop, :uv_prepare_stop, [:uv_prepare_t], :int

  attach_function :check_init, :uv_check_init, [:uv_loop_t, :uv_check_t], :int
  attach_function :check_start, :uv_check_start, [:uv_check_t, :uv_check_cb], :int
  attach_function :check_stop, :uv_check_stop, [:uv_check_t], :int

  attach_function :idle_init, :uv_idle_init, [:uv_loop_t, :uv_idle_t], :int
  attach_function :idle_start, :uv_idle_start, [:uv_idle_t, :uv_idle_cb], :int
  attach_function :idle_stop, :uv_idle_stop, [:uv_idle_t], :int

  attach_function :async_init, :uv_async_init, [:uv_loop_t, :uv_async_t, :uv_async_cb], :int
  attach_function :async_send, :uv_async_send, [:uv_async_t], :int

  attach_function :timer_init, :uv_timer_init, [:uv_loop_t, :uv_timer_t], :int
  attach_function :timer_start, :uv_timer_start, [:uv_timer_t, :uv_timer_cb, :int64_t, :int64_t], :int
  attach_function :timer_stop, :uv_timer_stop, [:uv_timer_t], :int
  attach_function :timer_again, :uv_timer_again, [:uv_timer_t], :int
  attach_function :timer_set_repeat, :uv_timer_set_repeat, [:uv_timer_t, :int64_t], :void
  attach_function :timer_get_repeat, :uv_timer_get_repeat, [:uv_timer_t], :int64_t

#  attach_function :ares_init_options, :uv_ares_init_options, [:uv_loop_t, :ares_channel, :ares_options, :int], :int
#  attach_function :ares_destroy, :uv_ares_destroy, [:uv_loop_t, :ares_channel], :void

  attach_function :getaddrinfo, :uv_getaddrinfo, [:uv_loop_t, :uv_getaddrinfo_t, :uv_getaddrinfo_cb, :string, :string, :addrinfo], :int
  attach_function :freeaddrinfo, :uv_freeaddrinfo, [:addrinfo], :void

  attach_function :spawn, :uv_spawn, [:uv_loop_t, :uv_process_t, :uv_options_t], :int
  attach_function :process_kill, :uv_process_kill, [:uv_process_t, :int], :int
  attach_function :kill, :uv_kill, [:int, :int], :uv_err_t
  attach_function :queue_work, :uv_queue_work, [:uv_loop_t, :uv_work_t, :uv_work_cb, :uv_after_work_cb], :int
  attach_function :setup_args, :uv_setup_args, [:int, :varargs], :varargs
  attach_function :get_process_title, :uv_get_process_title, [:pointer, :size_t], :uv_err_t
  attach_function :set_process_title, :uv_set_process_title, [:string], :uv_err_t
  attach_function :resident_set_memory, :uv_resident_set_memory, [:size_t], :uv_err_t

  attach_function :uptime, :uv_uptime, [:pointer], :uv_err_t
  attach_function :cpu_info, :uv_cpu_info, [:uv_cpu_info_t, :pointer], :uv_err_t
  attach_function :loadavg, :uv_loadavg, [:pointer], :void
  attach_function :free_cpu_info, :uv_free_cpu_info, [:uv_cpu_info_t, :int], :void
  attach_function :interface_addresses, :uv_interface_addresses, [:uv_interface_address_t, :pointer], :uv_err_t
  attach_function :free_interface_addresses, :uv_free_interface_addresses, [:uv_interface_address_t, :int], :void

#  attach_function :fs_req_result, :uv_fs_req_result, [:uv_fs_t], :ssize_t
#  attach_function :fs_req_stat, :uv_fs_req_stat, [:uv_fs_t], :uv_fs_stat_t
#  attach_function :fs_req_pointer, :uv_fs_req_pointer, [:uv_fs_t], :pointer

  attach_function :fs_req_cleanup, :uv_fs_req_cleanup, [:uv_fs_t], :void
  attach_function :fs_close, :uv_fs_close, [:uv_loop_t, :uv_fs_t, :uv_file, :uv_fs_cb], :int
  attach_function :fs_open, :uv_fs_open, [:uv_loop_t, :uv_fs_t, :string, :int, :int, :uv_fs_cb], :int
  attach_function :fs_read, :uv_fs_read, [:uv_loop_t, :uv_fs_t, :uv_file, :string, :size_t, :off_t, :uv_fs_cb], :int
  attach_function :fs_unlink, :uv_fs_unlink, [:uv_loop_t, :uv_fs_t, :string, :uv_fs_cb], :int
  attach_function :fs_write, :uv_fs_write, [:uv_loop_t, :uv_fs_t, :uv_file, :string, :size_t, :off_t, :uv_fs_cb], :int
  attach_function :fs_mkdir, :uv_fs_mkdir, [:uv_loop_t, :uv_fs_t, :string, :int, :uv_fs_cb], :int
  attach_function :fs_rmdir, :uv_fs_rmdir, [:uv_loop_t, :uv_fs_t, :string, :uv_fs_cb], :int
  attach_function :fs_readdir, :uv_fs_readdir, [:uv_loop_t, :uv_fs_t, :string, :int, :uv_fs_cb], :int
  attach_function :fs_stat, :uv_fs_stat, [:uv_loop_t, :uv_fs_t, :string, :uv_fs_cb], :int
  attach_function :fs_fstat, :uv_fs_fstat, [:uv_loop_t, :uv_fs_t, :uv_file, :uv_fs_cb], :int
  attach_function :fs_rename, :uv_fs_rename, [:uv_loop_t, :uv_fs_t, :string, :string, :uv_fs_cb], :int
  attach_function :fs_fsync, :uv_fs_fsync, [:uv_loop_t, :uv_fs_t, :uv_file, :uv_fs_cb], :int
  attach_function :fs_fdatasync, :uv_fs_fdatasync, [:uv_loop_t, :uv_fs_t, :uv_file, :uv_fs_cb], :int
  attach_function :fs_ftruncate, :uv_fs_ftruncate, [:uv_loop_t, :uv_fs_t, :uv_file, :off_t, :uv_fs_cb], :int
  attach_function :fs_sendfile, :uv_fs_sendfile, [:uv_loop_t, :uv_fs_t, :uv_file, :uv_file, :off_t, :size_t, :uv_fs_cb], :int
  attach_function :fs_chmod, :uv_fs_chmod, [:uv_loop_t, :uv_fs_t, :string, :int, :uv_fs_cb], :int
  attach_function :fs_utime, :uv_fs_utime, [:uv_loop_t, :uv_fs_t, :string, :double, :double, :uv_fs_cb], :int
  attach_function :fs_futime, :uv_fs_futime, [:uv_loop_t, :uv_fs_t, :uv_file, :double, :double, :uv_fs_cb], :int
  attach_function :fs_lstat, :uv_fs_lstat, [:uv_loop_t, :uv_fs_t, :string, :uv_fs_cb], :int
  attach_function :fs_link, :uv_fs_link, [:uv_loop_t, :uv_fs_t, :string, :string, :uv_fs_cb], :int
  attach_function :fs_symlink, :uv_fs_symlink, [:uv_loop_t, :uv_fs_t, :string, :string, :int, :uv_fs_cb], :int
  attach_function :fs_readlink, :uv_fs_readlink, [:uv_loop_t, :uv_fs_t, :string, :uv_fs_cb], :int
  attach_function :fs_fchmod, :uv_fs_fchmod, [:uv_loop_t, :uv_fs_t, :uv_file, :int, :uv_fs_cb], :int
  attach_function :fs_chown, :uv_fs_chown, [:uv_loop_t, :uv_fs_t, :string, :int, :int, :uv_fs_cb], :int
  attach_function :fs_fchown, :uv_fs_fchown, [:uv_loop_t, :uv_fs_t, :uv_file, :int, :int, :uv_fs_cb], :int

  attach_function :fs_event_init, :uv_fs_event_init, [:uv_loop_t, :uv_fs_event_t, :string, :uv_fs_event_cb, :int], :int

  attach_function :ip4_addr, :uv_ip4_addr, [:string, :int], :sockaddr_in
  attach_function :ip6_addr, :uv_ip6_addr, [:string, :int], :sockaddr_in6
  attach_function :ip4_name, :uv_ip4_name, [SockaddrIn.by_ref, :pointer, :size_t], :int
  attach_function :ip6_name, :uv_ip6_name, [SockaddrIn6.by_ref, :pointer, :size_t], :int

  attach_function :exepath, :uv_exepath, [:pointer, :size_t], :int
  attach_function :cwd, :uv_cwd, [:pointer, :size_t], :uv_err_t
  attach_function :chdir, :uv_chdir, [:string], :uv_err_t
  attach_function :get_free_memory, :uv_get_free_memory, [], :uint64
  attach_function :get_total_memory, :uv_get_total_memory, [], :uint64
  attach_function :hrtime, :uv_hrtime, [], :uint64
  attach_function :dlopen, :uv_dlopen, [:string, :uv_lib_t], :uv_err_t
  attach_function :dlclose, :uv_dlclose, [:uv_lib_t], :uv_err_t
  # attach_function :dlsym, :uv_dlsym, [:uv_lib_t], :ev_err_t
  # attach_function :dlerror, :uv_dlerror, [:uv_lib_t], :string
  # attach_function :dlerror_free, :uv_dlerror_free, [:uv_lib_t, :string], :void

  attach_function :mutex_init, :uv_mutex_init, [:uv_mutex_t], :int
  attach_function :mutex_destroy, :uv_mutex_destroy, [:uv_mutex_t], :void
  attach_function :mutex_lock, :uv_mutex_lock, [:uv_mutex_t], :void
  attach_function :mutex_trylock, :uv_mutex_trylock, [:uv_mutex_t], :int
  attach_function :mutex_unlock, :uv_mutex_unlock, [:uv_mutex_t], :void

  attach_function :rwlock_init, :uv_rwlock_init, [:uv_rwlock_t], :int
  attach_function :rwlock_destroy, :uv_rwlock_destroy, [:uv_rwlock_t], :void
  attach_function :rwlock_rdlock, :uv_rwlock_rdlock, [:uv_rwlock_t], :void
  attach_function :rwlock_tryrdlock, :uv_rwlock_tryrdlock, [:uv_rwlock_t], :int
  attach_function :rwlock_rdunlock, :uv_rwlock_rdunlock, [:uv_rwlock_t], :void
  attach_function :rwlock_wrlock, :uv_rwlock_wrlock, [:uv_rwlock_t], :void
  attach_function :rwlock_trywrlock, :uv_rwlock_trywrlock, [:uv_rwlock_t], :int
  attach_function :rwlock_wrunlock, :uv_rwlock_wrunlock, [:uv_rwlock_t], :void

  attach_function :once, :uv_once, [:uv_once_t, :uv_cb], :void
  attach_function :thread_create, :uv_thread_create, [:uv_thread_t, :uv_cb], :int
  attach_function :thread_join, :uv_thread_join, [:uv_thread_t], :int

  attach_function :handle_size, :uv_handle_size, [:uv_handle_type], :size_t
  attach_function :req_size, :uv_req_size, [:uv_req_type], :size_t

  def self.create_handle(type)
    UV.malloc(UV.handle_size(type))
  end

  def self.create_request(type)
    UV.malloc(UV.req_size(type))
  end

  autoload :Resource, 'uv/resource'
  autoload :Listener, 'uv/listener'
  autoload :Net, 'uv/net'
  autoload :Handle, 'uv/handle'
  autoload :Stream, 'uv/stream'
  autoload :Loop, 'uv/loop'
  autoload :Error, 'uv/error'
  autoload :Timer, 'uv/timer'
  autoload :TCP, 'uv/tcp'
  autoload :UDP, 'uv/udp'
  autoload :TTY, 'uv/tty'
  autoload :Pipe, 'uv/pipe'
  autoload :Prepare, 'uv/prepare'
  autoload :Check, 'uv/check'
  autoload :Idle, 'uv/idle'
  autoload :Async, 'uv/async'
  autoload :Filesystem, 'uv/filesystem'
  autoload :File, 'uv/file'
  autoload :FSEvent, 'uv/fs_event'
  autoload :Assertions, 'uv/assertions'
end
