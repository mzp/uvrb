module UV
  typedef :long,   :blksize_t
  typedef :uint32, :in_addr_t
  typedef :ushort, :in_port_t
  typedef :uint,   :dev_t
  typedef :ushort, :ino_t
  typedef :int64,  :time64_t

  # win32 has a different uv_buf_t layout to everything else.
  class UvBuf < FFI::Struct
    layout :len, :ulong, :base, :pointer
  end

  # win32 uses _stati64
  class UvFSStat < FFI::Struct
    layout :st_dev,  :dev_t,
           :st_ino,  :ino_t,
           :st_mode, :ushort,
           :st_nlink,:short,
           :st_uid,  :short,
           :st_gid,  :short,
           :st_rdev, :dev_t,
           :st_size, :int64,
           :st_atime,:time64_t,
           :st_mtime,:time64_t,
           :st_ctime,:time64_t
  end
end
