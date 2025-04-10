# frozen_string_literal: true

module Covenant
  module Comparable
    def self.empty
      StructureComparator.new do |_left, _right|
        Result.success
      end
    end

    def self.comparable
      StructureComparator.new do |left, right|
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
      StructureComparator.new do |left, right|
        Result.from_array(left.tag) do
          left.props.props.flat_map do |prop|
            compare_prop_to_struct(prop, right)
          end
        end
      end
    end

    def self.compare_prop_to_struct(prop, right)
      other_prop = right.props[prop.tag]
      case prop
      when Types::Prop
        return Result.success(prop.tag) if other_prop

        Result.failure(prop.tag, 'missing prop')
      when Types::Struct
        if other_prop.nil?
          Result.failure(prop.tag, 'Missing struct')
        else
          check_struct.call(prop, other_prop)
        end
      end
    end
  end
end
