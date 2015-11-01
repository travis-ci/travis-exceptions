# require 'core_ext/module/prepend_to'
#
# module Travis
#   module Exceptions
#     module Handling
#       def rescues(name, opts = {})
#         prepend_to(name) do |object, method, *args, &block|
#           if Travis.env == 'test'
#             method.call(*args, &block)
#           else
#             begin
#               method.call(*args, &block)
#             rescue opts[:from] || Exception => e
#               Exceptions.handle(e)
#               raise if opts[:raise] && Array(opts[:raise]).include?(e.class)
#             end
#           end
#         end
#       end
#     end
#   end
# end
