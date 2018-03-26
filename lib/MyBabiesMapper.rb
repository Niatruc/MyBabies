require_relative 'Support.rb'

class MyBabiesMapper
	attr_accessor :sql_mapper_hash
	attr_accessor :insert, :delete, :select, :update

	def initialize(mapper_str)
		this_mapper = self

		@isIniting = true

		@initingLevel = 1

		# 载入mapper散列
		eval "@sql_mapper_hash=" + mapper_str

		# 将所有公共sql语句存到实例变量中（以公共sql的id为变量名）
		@sql_mapper_hash[:mapper][:sql].each do |common_sql_id, common_sql_str|  
			self.singleton_class.class_eval do 
				attr_accessor common_sql_id
			end
			self.instance_variable_set "@"+common_sql_id.to_s, mb_pre_treat_str(mb_flush_tn(common_sql_str))
		end

		@initingLevel = 2

		# 将增删查改的所有sql语句映射为本地方法
		[:insert, :delete, :select, :update].each do |mb_func_type|
			@sql_mapper_hash[:mapper][mb_func_type].each do |mb_func_id, mb_func_body|
				# 处理引用公共sql的地方（宏替换）
				puts "这里是initialize"
				p mb_sql_str = mb_pre_treat_str(mb_flush_tn(mb_func_body[:sql]))

				self.singleton_class.class_eval do
					define_method(mb_func_id) do |mb_params|
						# 创建一个闭包，用于存放参数
						params_closure = eval 'binding'

						# 将散列中所有参数转为params_closure闭包中的本地变量
						mb_params.each do |k, v|
							# eval(k.to_s + "= v", params_closure)
							params_closure.local_variable_set(k, mb_pre_treat_param(v))
						end

						# 替换sql语句中所有参数名称，返回完整可执行的sql语句
						puts "这里是mapper方法调用"
						p params_closure.local_variables
						mb_pre_treat_str(mb_flush_tn(mb_sql_str), params_closure)
					end
				end
			end if @sql_mapper_hash[:mapper][mb_func_type]
		end

		# 定义if、foreach等方法
		self.instance_eval do
			def mb_if(bool, &blk)
				p bool
				if bool
					blk.call
				end
			end

			def mb_foreach(collection_opt, &blk)
				p collection_opt
				str = ""

				str += blk.call(collection[:collection].shift)

				collection_opt[:collection].each do |i|
					str += collection_opt[:separator] + blk.call(i)
				end

				collection_opt[:open] + str + collection_opt[:close]
			end
		end

		@isIniting = false
	end

	# 对字符串进行预处理，返回字符串
	def mb_pre_treat_str(str, context=binding)
		print "这里是mb_pre_treat_str： ", str, "\n"
		context.eval '"' + str + '"'
	end

	# 将\t和\n替换成空格
	def mb_flush_tn(str)
		str.gsub(/\t+\n*|\n+\t*/, ' ')
	end

	# 对传入参数
	def mb_pre_treat_param(param)
		pc = param.class
		if pc == String
			param.gsub(/'|"/) { |match| '\\'+param }
		end
		param
	end
	
	def method_missing(f, *args, &blk)
		if !@isIniting
			puts "MyBabies Errors: missing params '#{f}'"
		elsif [:mb_if, :mb_foreach].include?(f)
			params = args.to_s
			params = params[1, params.length-2]
			blk_result = blk.call
			blk_params = ""

			# 当是if语句的时候，参数是一个布尔表达式字符串，需要eval
			if @initingLevel >= 2
				params = "eval(#{params}, params_closure)"
				if f == :mb_foreach
					blk_params = "|mb_item|"
				end
			end

			print "这里是method_missing: "
			p %Q{
				\#{
					#{f}(#{params}) { #{blk_params}
						mb_pre_treat_str(%Q{#{blk_result}})
					}
				}
			}
		else
			"\#{#{f.to_s}}"
		end
	end
end

# mb_if(a,b) {
# 	mb_pre_treat_str("\#{mb_if(c) {
# 							mb_pre_treat_str(%Q{where data=#{d}})
# 						}}
# 					 \#{mb_if(d) {
# 							mb_pre_treat_str(%Q{where data=#{e}})
# 					 	}}
# 					")
# }

# mb_if(a,b) {
# 	%Q{
# 		#{
# 			mb_if(c) {
# 				%Q{where data=#{d}}
# 			}
# 		}

# 		#{
# 			mb_if(d) {
# 				%Q{where data=#{e}}
# 			}
# 		}

# 	}
# }

	