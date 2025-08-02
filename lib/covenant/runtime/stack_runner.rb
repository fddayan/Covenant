# frozen_string_literal: true

module Covenant
  module Runtime
    class StackRunner
      def initialize(command_registry) = @command_registry = command_registry

      def call(contract, input)
        stack = [{ contract: contract, input: input, continuation: nil }]

        while stack.any?
          frame = stack.pop
          result = process_frame(frame, stack)
          return result if stack.empty?
        end
      end

      private

      def process_frame(frame, stack) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
        contract = frame[:contract]
        input = frame[:input]
        continuation = frame[:continuation]

        case contract
        when Contracts::Contract
          Executor.new(@command_registry, contract).call(input)
        when Compositions::Map
          if continuation == :map_next
            stack.push({ contract: contract.next_contract, input: input, continuation: nil })
          else
            stack.push({ contract: contract, input: nil, continuation: :map_next })
            stack.push({ contract: contract.prev_contract, input: input, continuation: nil })
          end
          nil
        when Compositions::Tee
          if continuation == :tee_next
            stack.push({ contract: contract.next_contract, input: input, continuation: nil })
            input
          else
            stack.push({ contract: contract, input: input, continuation: :tee_next })
            stack.push({ contract: contract.prev_contract, input: input, continuation: nil })
          end
          nil
        when Compositions::OrElse
          if continuation == :or_else_check
            if input.failure?
              stack.push({ contract: contract.next_contract, input: frame[:original_input],
                           continuation: nil })
            end
            input
          else
            stack.push({ contract: contract, input: input, continuation: :or_else_check,
                         original_input: input })
            stack.push({ contract: contract.prev_contract, input: input, continuation: nil })
          end
          nil
        when Compositions::Retry
          call_with_retry(contract, input)
        when Compositions::Match
          if continuation == :match_branch
            if input.success?
              stack.push({ contract: contract.success_contract, input: input, continuation: nil })
            else
              stack.push({ contract: contract.failure_contract, input: input, continuation: nil })
            end
          else
            stack.push({ contract: contract, input: nil, continuation: :match_branch })
            stack.push({ contract: contract.prev_contract, input: input, continuation: nil })
          end
          nil
        when Compositions::Timeout
          call_with_timeout(contract, input)
        when Compositions::Transformer
          if continuation == :transformer_transform
            contract.call(input)
          else
            stack.push({ contract: contract, input: nil, continuation: :transformer_transform })
            stack.push({ contract: contract.prev_contract, input: input, continuation: nil })
          end
          nil
        else
          raise "Unknown effect type: #{contract.class}"
        end
      end

      def call_with_retry(contract, input)
        attempts = 0
        begin
          call(contract.contract, input)
        rescue StandardError => e
          attempts += 1
          retry if attempts < contract.max_attempts
          raise e
        end
      end

      def call_with_timeout(contract, input)
        result = nil
        Timeout.timeout(contract.seconds) do
          result = call(contract.contract, input)
        end
        result
      end
    end
  end
end
