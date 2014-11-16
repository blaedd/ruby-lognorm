require 'ffi'
require 'lognorm/json'
require 'lognorm/version'

# FFI Wrapper around liblognorm, a library for normalizing logs.
# 
# @author David MacKinnon <blaedd@gmail.com>
# 
module Lognorm
  extend FFI::Library
  ffi_lib ['lognorm', 'liblognorm.so.1']

  # An instance of the lognorm library.
  class Ctx < FFI::ManagedStruct
    layout :objID, :uint,
      :dbgCG, :pointer,
      :ptree, :pointer,
      :pas, :pointer,
      :nNodes, :uint,
      :rulePrefix, :pointer

    # Calls the appropriate release method on object gc
    def self.release(pointer)
      Lognorm.exitCtx(pointer) unless pointer.null?
    end

    # Load rules from the given filename
    def loadSamples(filename)
      return Lognorm.ln_loadSamples(self, filename) == 0 ? true : false
    end

    # We attach a basic debug callback during initialization, so enableDebug
    # actually does something.
    def initialize(pointer)
      super(pointer)
      debugCB = Proc.new do |cookie, msg, msgLen|
        printf("lognorm: %s\n", msg)
      end
      setDebugCB(debugCB)
    end

    # normalize a log line. 
    # The Lognorm::JSON::JsonObject we get back from liblognorm is non-trivial to iterate
    # over, so for now, the ugly hack of converting to a string and reparsing
    # with the Ruby json gem. 
    def normalize(logline)
      @json_ptr = FFI::MemoryPointer.new(:pointer)
      if Lognorm.ln_normalize(self, logline, logline.bytesize,@json_ptr) == 0
        @json_obj = Lognorm::JSON::JsonObject.new(@json_ptr.read_pointer)
        return @json_obj.to_native
      else
        return nil
      end
    end

    # enable debug callbacks
    def enableDebug(yesorno)
      case yesorno
        when /yes/i, 1, true
          debug=1
        when /no/i, 0, false
          debug=0
        else
          raise ArgumentError.new(
            "enableDebug method must be called with 0 or 1, not #{yesorno}.")
      end
      Lognorm.ln_enableDebug(self, debug)
    end

    # Set the debug callback
    #  cb - The callback function
    #  cookie - Opaque cookie to be passed down to debug handler.
    def setDebugCB(cb, cookie=nil)
      return Lognorm.ln_setDebugCB(self, cb, cookie)
    end

  end

  # Definition of the debug callback
  callback :debugCallback, [:pointer, :string, :size_t], :void

  # Minimal functions required to be useful.
  attach_function :exitCtx, :ln_exitCtx, [Ctx.by_ref], :int
  attach_function :initCtx, :ln_initCtx, [], Ctx.by_ref
  attach_function :ln_enableDebug, :ln_enableDebug, [Ctx.by_ref, :int], :void
  attach_function :ln_loadSamples, :ln_loadSamples, [Ctx.by_ref, :string], :int
  attach_function :ln_normalize, :ln_normalize,
    [Ctx.by_ref, :string, :size_t, :pointer], :int
  attach_function :ln_setDebugCB, :ln_setDebugCB,
    [Ctx.by_ref, :debugCallback, :pointer], :int
  attach_function :version, :ln_version, [], :string
end
