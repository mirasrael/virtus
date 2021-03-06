module Virtus
  class Attribute

    # EmbeddedValue
    #
    # @example
    #
    #   class Address
    #     include Virtus
    #
    #     attribute :street,  String
    #     attribute :zipcode, String
    #     attribute :city,    String
    #   end
    #
    #   class User
    #     include Virtus
    #
    #     attribute :address, Address
    #   end
    #
    #   user = User.new(:address => {
    #     :street => 'Street 1/2', :zipcode => '12345', :city => 'NYC' })
    #
    class EmbeddedValue < Attribute
      TYPES = [Struct, OpenStruct, Virtus, Model::Constructor].freeze

      # Abstract EV coercer class
      #
      # @private
      class Coercer
        attr_reader :primitive

        def initialize(primitive)
          @primitive = primitive
        end

      end # Coercer

      # Builds Struct-like instance with attributes passed to the constructor as
      # a list of args rather than a hash
      #
      # @private
      class FromStruct < Coercer

        # @api public
        def call(input)
          if input.kind_of?(primitive)
            input
          elsif not input.nil?
            primitive.new(*input)
          end
        end

      end # FromStruct

      # Builds OpenStruct-like instance with attributes passed to the constructor
      # as a hash
      #
      # @private
      class FromOpenStruct < Coercer

        # @api public
        def call(input)
          if input.kind_of?(primitive)
            input
          elsif not input.nil?
            primitive.new(input)
          end
        end

      end # FromOpenStruct

      # @api private
      def self.handles?(klass)
        klass.is_a?(Class) && TYPES.any? { |type| klass <= type }
      end

      # @api private
      def self.build_type(definition)
        Axiom::Types::Object.new { primitive definition.primitive }
      end

      # @api private
      def self.build_coercer(type, _options)
        primitive = type.primitive

        if primitive < Virtus || primitive < Model::Constructor || primitive <= OpenStruct
          FromOpenStruct.new(primitive)
        elsif primitive < Struct
          FromStruct.new(primitive)
        end
      end

    end # class EmbeddedValue

  end # class Attribute
end # module Virtus
