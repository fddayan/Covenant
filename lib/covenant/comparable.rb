# frozen_string_literal: true

module Covenant
  module Comparable
    def self.empty
      SchemaComparator.new do |_left, _right|
        Result.success
      end
    end

    def self.comparable
      SchemaComparator.new do |left, right|
        { sucess: left == right, errors: 'Structs are not comparable' }
      end
    end

    # def self.tags
    #   StructureComparator.new do |left, right|
    #     { success: left.tag == right.tag, errors: "Invalid tags #{left.tag} != #{right.tag}" }
    #   end
    # end

    # def self.stuct_missing_props
    #   StructureComparator.new do |left, right|
    #     struct_diff = left - right

    #     { success: struct_diff.empty?, errors: "Missing props: #{struct_diff.keys.join(', ')}" }
    #   end
    # end

    # def self.check_nested_structs
    #   StructureComparator.new do |left, right|
    #     compositions = left.compositions - right.compositions
    #     compositions.group_by(&:tag).values.filter_map do |structs|
    #       stuct_missing_props.call(structs.first, structs.last)
    #     end
    #   end
    # end

    # def self.deep_tr_struct(struct)
    #   struct.props.flat_map do |prop|
    #     case prop
    #     when Types::Prop
    #       [prop]
    #     when Types::Struct
    #       [prop] + deep_traverse_struct(prop)
    #     end
    #   end
    # end

    def self.check_struct
      SchemaComparator.new do |left, right|
        next Result.failure(left.tag, 'is not a struct') unless left.is_a?(Types::Schema)
        next Result.failure(right.tag, 'is not a struct') unless right.is_a?(Types::Schema)

        Result.from_array(left.tag) do
          left.zip(right).filter_map do |left_prop, right_prop|
            compare_props(left_prop, right_prop)
          end
        end
      end
    end

    def self.compare_props(left_prop, right_prop)
      case left_prop
      when Types::Scalar
        comnpare_scalars(left_prop, right_prop)
      when Types::Schema
        compare_schemas(left_prop, right_prop) || check_struct.call(left_prop, right_prop)
      end
    end

    def self.comnpare_scalars(left, right)
      return failure(left.tag, 'missing') unless right

      return failure(left.tag, 'target is not Scalar') unless right.is_a?(Types::Scalar)

      return failure(left.tag, 'tags are not the same') unless left.tag == right.tag

      return unless left.is_a?(Types::Scalar) && !right.is_a?(Types::Scalar)

      failure(left.tag, 'one is Scalar the other is not')
    end

    def self.compare_schemas(left, right)
      return failure(left.tag, 'missing') unless right

      return failure(left.tag, 'target is not Schema') unless right.is_a?(Types::Schema)
      return failure(left.tag, 'tags are not the same') unless left.tag == right.tag
      return unless left.is_a?(Types::Schema) && !right.is_a?(Types::Schema)

      failure(left.tag, 'one is a Schema the other is not')
    end

    def self.failure(tag, message) = Result.failure(tag, message)

    # def self.compare_prop_to_struct(prop, right)
    #   other_prop = right.props[prop.tag]
    #   case prop
    #   when Types::Scalar
    #     return Result.success(prop.tag) if other_prop

    #     Result.failure(prop.tag, 'missing prop')
    #   when Types::Schema
    #     if other_prop.nil?
    #       Result.failure(prop.tag, 'missing schema')
    #     else
    #       check_struct.call(prop, other_prop)
    #     end
    #   end
    # end
  end
end
