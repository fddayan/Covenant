# frozen_string_literal: true

module Covenant
  module Runtime
    class StackRunner
      def initialize(command_registry) = @command_registry = command_registry

      def call(contract, input)
        instructions = contract.to_instruction
        stack = [{ instruction: instructions, input: input, result: nil }]

        while stack.any?
          frame = stack.pop
          result = execute_instruction(frame, stack)
          return result if stack.empty? && result
        end
      end

      private

      def execute_instruction(frame, stack) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        instruction = frame[:instruction]
        input = frame[:input]
        result = frame[:result]

        case instruction[0]
        when :execute
          Executor.new(@command_registry, instruction[1]).call(input)
        when :sequence
          if result
            stack.push({ instruction: instruction[2], input: result, result: nil })
          else
            stack.push({ instruction: [:sequence, nil, instruction[2]], input: nil, result: nil })
            stack.push({ instruction: instruction[1], input: input, result: nil })
          end
          nil
        when :map_result
          stack.push({ instruction: instruction[1].to_instruction, input: result, result: nil })
          nil
        when :tee
          stack.push({ instruction: instruction[2], input: input, result: nil })
          stack.push({ instruction: instruction[1], input: input, result: nil })
          nil
        when :or_else
          stack.push({ instruction: [:or_else_check, instruction[2]], input: input, result: nil })
          stack.push({ instruction: instruction[1], input: input, result: nil })
          nil
        when :or_else_check
          if result&.failure?
            stack.push({ instruction: instruction[1].to_instruction, input: input, result: nil })
          end
          result
        when :match
          stack.push({ instruction: [:match_branch, instruction[2], instruction[3]], input: nil,
                       result: nil })
          stack.push({ instruction: instruction[1], input: input, result: nil })
          nil
        when :match_branch
          if result&.success?
            stack.push({ instruction: instruction[1].to_instruction, input: result, result: nil })
          else
            stack.push({ instruction: instruction[2].to_instruction, input: result, result: nil })
          end
          nil
        when :transformer
          stack.push({ instruction: [:transform, instruction[2]], input: nil, result: nil })
          stack.push({ instruction: instruction[1], input: input, result: nil })
          nil
        when :transform
          instruction[1].call(result)
        when :retry
          call_with_retry(instruction[1], instruction[2], input)
        when :timeout
          call_with_timeout(instruction[1], instruction[2], input)
        else
          raise "Unknown instruction type: #{instruction[0]}"
        end
      end

      def call_with_retry(contract_instruction, max_attempts, input)
        attempts = 0
        begin
          execute_single_instruction(contract_instruction, input)
        rescue StandardError => e
          attempts += 1
          retry if attempts < max_attempts
          raise e
        end
      end

      def call_with_timeout(contract_instruction, seconds, input)
        # @type var result: ::Covenant::Runtime::ExecutionResult | nil
        result = nil
        Timeout.timeout(seconds) do
          result = execute_single_instruction(contract_instruction, input)
        end
        result
      end

      def execute_single_instruction(instruction, input)
        temp_stack = [{ instruction: instruction, input: input, result: nil }]

        while temp_stack.any?
          frame = temp_stack.pop
          result = execute_instruction(frame, temp_stack)
          return result if temp_stack.empty? && result
        end
      end
    end
  end
end
