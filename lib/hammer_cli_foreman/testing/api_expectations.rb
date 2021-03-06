module HammerCLIForeman
  module Testing
    module APIExpectations
      class BlockMatcher < Mocha::ParameterMatchers::Base
        def initialize(resource=nil, action=nil, &block)
          @expected_resource = resource
          @expected_action = action
          @block = block if block_given?
        end

        def matches?(actual_parameters)
          action, params, headers, options = actual_parameters.shift(4)
          action_name = action.name.to_s
          resource_name = action.resource.to_s

          result = true
          result &&= (resource_name == @expected_resource.to_s) unless @expected_resource.nil?
          result &&= (action_name == @expected_action.to_s) unless @expected_action.nil?
          result &&= @block.call(params) if @block
          result
        end

        def mocha_inspect
          res = @expected_resource.nil? ? 'any_resource' : ":#{@expected_resource}"
          act = @expected_action.nil? ? 'any_action' : ":#{@expected_action}"
          blk = @block ? '&block' : '*any_argument'
          "#{res}, #{act}, #{blk}"
        end
      end

      module ExpectationExtensions
        def method_signature
          "#{@note}\n  #{super}"
        end

        def set_note(note)
          @note = note
        end
      end

      def api_expects(resource=nil, action=nil, note=nil, &block)
        ex = ApipieBindings::API.any_instance.expects(:call_action)
        ex.extend(ExpectationExtensions)
        ex.with(BlockMatcher.new(resource, action, &block))
        ex.set_note(note)
        ex
      end

      def api_expects_no_call
        ApipieBindings::API.any_instance.expects(:call_action).never
      end

      def index_response(items)
        cnt = items.length
        {
          "total" => cnt,
          "subtotal" => cnt,
          "page" => 1,
          "per_page" => cnt,
          "search" => "",
          "sort" => {
            "by" => nil,
            "order" => nil
          },
          "results" => items
        }
      end
    end
  end
end
