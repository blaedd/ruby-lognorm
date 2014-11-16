require 'ffi'
require 'json'

module Lognorm

  # Minimal FFI Wrapper around json-c, just enough for liblognorm usage.
  module JSON
    extend FFI::Library
    ffi_lib ['json-c', 'libjson-c.so.2']
    
    typedef :int, :json_bool

    enum :jsonType, [:json_type_null,
                     :json_type_boolean,
                     :json_type_double,
                     :json_type_int,
                     :json_type_object,
                     :json_type_array,
                     :json_type_string ]

    class CString < FFI::Struct
      layout :str, :pointer,
        :len, :int
    end

    class JsonData < FFI::Union
      layout :c_boolean, :json_bool,
        :c_double, :double,
        :c_int64, :int64,
        :c_object, :pointer,
        :c_array, :pointer,
        :c_string, CString
    end

    # The main struct that represents a JSON object
    class JsonObject < FFI::ManagedStruct
      layout :o_type, :jsonType,
        :delete_fn, :pointer,
        :string_fn, :pointer,
        :_ref_count, :int,
        :pb, :pointer,
        :o, JsonData,
        :user_delete_fn, :pointer,
        :userdata, :pointer

      # Stringify the object
      def to_s
        return Lognorm::JSON.to_string(self)
      end

      # Convert to a ruby hash using the json module
      def to_native
        return ::JSON.parse(to_s)
      end

      def self.release(pointer)
        Lognorm::JSON.json_object_put(pointer) unless pointer.null?
      end

    end
    typedef :pointer, :json_object_iter
    attach_function :to_string, :json_object_to_json_string, [JsonObject.by_ref], :string
    attach_function :json_object_put, :json_object_put, [JsonObject.by_ref], :void
  end
end



          
        
