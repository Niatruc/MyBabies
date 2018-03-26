# puts "1233333333333333333333333333333333312333333333333333333333333333333333"
class NilClass
	def +(val)
		val.to_s
	end
end

class String
	alias_method :mb_str_concat, :+
	def +(val)
		mb_str_concat(val.to_s)
	end
end

# module Kernel
# 	def mb_
		
# 	end
# end
# class C
# 	alias :a :b
# 	def b(val)
# 		a(val)
# 	end
# end