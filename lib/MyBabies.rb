module MyBabies
	MyBabies::RB_LOAD_PATH = 'D:\jruby-9.1.12.0\test\Mybabies\test\mapper\\'

	class MyBabiesFactory

		class << self
			def load_mapper_file(f)
				mapper_str = ""
				File.foreach(RB_LOAD_PATH + f) do |line|  
					mapper_str += line
				end
				mapper_str
			end

			def create_mapper(f)
				mm = MyBabiesMapper.new

				mm
			end
		end

		class MyBabiesMapper<BasicObject
			attr_accessor :sql_mapper_hash
			attr_accessor :insert, :delete, :select, :update

			def initialize(mapper_str)
				this_mapper = self

				@isIniting = true

				# 载入mapper散列
				eval "@sql_mapper_hash=" + mapper_str

				# 将所有公共sql语句存到实例变量中（以公共sql的id为变量名）
				@sql_mapper_hash[:mapper][:sql].each do |common_sql_id, common_sql_str|  
					self.singleton_class.class_eval do |variable|
						attr_accessor common_sql_id
						eval "this_mapper." + common_sql_id.to_s + "=" + mb_pre_treat_str(common_sql_str)
					end
				end

				# 将增删查改的所有sql语句映射为本地方法
				[:insert, :delete, :select, :update].each do |e|
					@sql_mapper_hash[:mapper][e].each do |id, content|
						its_sql = mb_pre_treat_str(content[:sql])

						define_method(id) do |params|
							# 创建一个闭包，用于存放参数
							params_closure = eval 'binding'

							# 将散列中所有参数转为params_closure闭包中的本地变量
							params.each do |k, v|
								# eval(k.to_s + "= v", params_closure)
								params_closure.local_variable_set(k, v)
							end

							# 替换sql语句中所有参数名称，返回完整可执行的sql语句
							mb_pre_treat_str(its_sql, params_closure)
						end
					end
				end

				@isIniting = false
			end

			# 对字符串进行预处理，返回字符串
			def mb_pre_treat_str(str, context=binding)
				context.eval '"' + str + '"'
			end
			
			def method_missing(f, *args)
				if !@isIniting
					puts "Errors: missing params '#{f}'"
				end
				"\#{#{f.to_s}}"
			end
		end
	end
end